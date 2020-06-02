# frozen_string_literal: true

require "fileutils"
require "template_helper"
require "plugins_helper"
require "dotenv"
require "dotenv/tasks"
require "colorize"
require "active_support/core_ext/string"

desc "Add plugins dependencies"
task generate_plugins: :dotenv do
  plugins_json = PluginsHelper.plugins_configuration_json
  plugins_maven_repos = []
  plugins_dependencies = []
  project_gradle_dependencies = []
  project_dependencies_names = []
  project_dependencies_paths = []

  plugins_json.each do |plugin_configuration|
    plugin = plugin_configuration["plugin"]
    next unless plugin["platform"].try(:match?, /amazon|android/)

    if plugin_configuration["configuration_json"].present?
      AppBuildHelper.expand_assets(
        plugin_configuration["configuration_json"][PluginsHelper::ASSETS_BUNDLE_KEY],
        false,
      )
    end

    # Making sure copying styles.json is not skipped and it happens only ones.
    if plugin["react_native"] && !File.exist?("#{AppBuildHelper.assets_dir}/styles.json")

      puts "Copying styles.json to assets folder".yellow

      unless File.exist?("#{AppBuildHelper.project_dir}/styles.json")
        puts "Styles.json doesn't exist, Downloading from #{ENV['styles_url']}".yellow
        Curl::Easy.download(ENV["styles_url"])
      end

      FileUtils.cp(
        "#{AppBuildHelper.project_dir}/styles.json",
        "#{AppBuildHelper.assets_dir}/styles.json",
      )
    end

    next if PluginsHelper.pure_js_dependency?(plugin)

    if plugin["dependency_repository_url"].present?
      plugins_maven_repos.concat(plugin["dependency_repository_url"])
    end

    api_resources = plugin["api"]["resources"]

    if api_resources && plugin_configuration["configuration_json"].present?
      custom_keys = api_resources.values
      ENV["additional_resources"] = plugin_configuration["configuration_json"]
                                    .select { |conf| custom_keys.include?(conf) }
                                    .to_json
    end

    unless PluginsHelper.skip_gradle_import?(plugin)
      plugins_dependencies << "#{plugin['dependency_name']}:#{plugin['dependency_version']}"
    end

    PluginsHelper.add_plugin_class_name(plugin)
    PluginsHelper.add_proguard_rules(plugin)

    next unless plugin["react_native"]

    # React Native dependencies
    puts "Adding React Native #{plugin['name']} plugin...".yellow

    plugin["extra_dependencies"]&.each do |dependency|
      plugins_dependencies << "#{dependency.keys.first}:#{dependency.values.first}"
    end

    unless plugin["project_dependencies"].nil?
      plugin["project_dependencies"].each do |dependency|
        project_gradle_dependencies <<
          "implementation (project(':#{dependency.keys.first}')) {\n"\
        "\t\texclude group: 'com.applicaster', module: 'applicaster-android-sdk'\n"\
        "\t}"
      end

      plugin["project_dependencies"].each do |dependency|
        project_dependencies_names << dependency.keys.first.to_s
      end

      plugin["project_dependencies"].each do |dependency|
        project_dependencies_paths <<
          "project(':#{dependency.keys.first}').projectDir = "\
        "new File('#{dependency.values.first}')"
      end
    end

    next if plugin["npm_dependencies"].nil?

    puts "Installing npm dependencies ...".yellow

    plugin["npm_dependencies"].each do |dependency|
      system("npm install -S #{dependency}")
    end
  end

  ENV["plugins_maven_repos"] = plugins_maven_repos.reject(&:empty?).uniq.to_json
  PluginsHelper.add_plugins_maven_repos

  ENV["plugins_dependencies"] = plugins_dependencies.reject(&:empty?).uniq.to_json
  ENV["project_gradle_dependencies"] = project_gradle_dependencies.reject(&:empty?).uniq.to_json
  ENV["project_dependencies_names"] = project_dependencies_names.reject(&:empty?).uniq.to_json
  ENV["project_dependencies_paths"] = project_dependencies_paths.reject(&:empty?).uniq.to_json

  PluginsHelper.add_plugins_dependencies
  PluginsHelper.add_project_dependencies
  PluginsHelper.add_additional_strings
end
