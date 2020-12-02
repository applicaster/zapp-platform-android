# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module PluginsHelper
  ASSETS_BUNDLE_KEY = "android_assets_bundle"
  SINGLE_BUNDLE_ID = "SingleBundleReactNative"

  module_function

  def plugins_configuration_json
    return unless ENV["plugin_configurations_url"].present?

    unless File.exist?("#{AppBuildHelper.project_dir}/plugin_configurations.json")
      puts "Downloading plugins_configuration.json from #{ENV['plugin_configurations_url']}".yellow
      Curl::Easy.download(ENV["plugin_configurations_url"])

      FileUtils.cp(
        "#{AppBuildHelper.project_dir}/plugin_configurations.json",
        "#{AppBuildHelper.resources_dir}/raw/plugin_configurations.json",
      )
    end

    JSON.parse(File.read("#{AppBuildHelper.project_dir}/plugin_configurations.json"))
  end

  def plugin_config(plugin_id)
    plugins_configuration_json.find do |config|
      config.dig("plugin", "identifier") == plugin_id
    end
  end

  def add_proguard_rules(plugin)
    puts "adding #{plugin['identifier']} plugin proguard rules".green

    File.open("#{AppBuildHelper.project_dir}/app/proguard-rules.pro", "a") do |file|
      file << "\n#-------------------- #{plugin['name']} --------------------#\n\n"
      file << "#{plugin['api']['proguard_rules']}\n"
    end
  end

  def add_plugin_class_name(plugin)
    puts "adding #{plugin['identifier']} 'plugin_class_name' to modularapp.properties".green

    File.open("#{AppBuildHelper.assets_dir}/modularapp.properties", "a") do |file|
      file << "\n#{plugin['api']['class_name']}\n"
    end
  end

  def add_plugins_maven_repos
    puts "adding plugins maven repos urls to top level build.gradle".green
    TemplateHelper.new.render_template(WorkspaceHelper.top_level_build_gradle_erb, "build.gradle")
  end

  def add_plugins_dependencies
    puts "adding plugins dependencies to build.gradle".green
    build_gradle_template = WorkspaceHelper.build_gradle_erb
    TemplateHelper.new.render_template(build_gradle_template, "app/build.gradle")
  end

  def add_react_native_dependency
    puts "adding react native dependencies to main gradle folder".green
    build_gradle_template = "react-native.gradle.erb"
    TemplateHelper.new.render_template(build_gradle_template, "gradle/react-native.gradle")
  end

  def add_package_json_dependencies(deps_object, package_json_path)
    package_json = JSON.parse(File.read(package_json_path))
    package_json["dependencies"] = package_json["dependencies"].merge(deps_object)

    File.open(File.join("package.json"), "w+") do |dst|
      dst.write(package_json.to_json)
    end
  end

  def add_project_dependencies
    puts "adding project dependencies to settings.gradle".green
    if WorkspaceHelper.quickbrick?
      TemplateHelper.new.render_template("qb_settings.gradle.erb", "settings.gradle")
    else
      TemplateHelper.new.render_template("settings.gradle.erb", "settings.gradle")
    end
  end

  def plugins_dependencies
    return unless ENV["plugins_dependencies"]

    dependencies = JSON.parse(ENV["plugins_dependencies"])
    result = ""

    dependencies.each do |dependency|
      result += "\timplementation (\"#{dependency}\") "\
      "{#{DependencyHelper.transitive_excluded_projects}}\n"
    end

    result
  end

  def project_gradle_dependencies
    return unless ENV["project_gradle_dependencies"]

    dependencies = JSON.parse(ENV["project_gradle_dependencies"])
    result = ""

    dependencies.each do |dependency|
      result += "#{dependency}\n"
    end

    result
  end

  def additional_configuration
    return unless ENV["additional_resources"]

    configurations = JSON.parse(ENV["additional_resources"])

    if configurations
      additional_resources = configurations.map do |key, value|
        "<string name=\"#{key}\">#{value.encode(xml: :attr)}</string>"
      end

      additional_resources.join("\n")
    end
  end

  def add_additional_strings
    puts "Add additional strings.xml...".cyan
    TemplateHelper.new.render_template("strings.xml.erb", "app/src/main/res/values/strings.xml")
  end

  def project_dependencies_names
    return unless ENV["project_dependencies_names"]

    dependencies = JSON.parse(ENV["project_dependencies_names"])
    result = ""

    dependencies.each do |dependency|
      result += ",':#{dependency}'"
    end

    result
  end

  def project_dependencies_paths
    return unless ENV["project_dependencies_paths"]

    dependencies = JSON.parse(ENV["project_dependencies_paths"])
    result = ""

    dependencies.each do |dependency|
      result += "#{dependency}\n"
    end

    result
  end

  def plugins_maven_repos
    return unless ENV["plugins_maven_repos"]

    repos = JSON.parse(ENV["plugins_maven_repos"])

    result = ""

    repos.each do |repo_data|
      result += if repo_data.is_a?(String)
                  "maven { url \'#{repo_data}\' }\n\t"
                else
                  # do not change indentation
                  %(maven {
                    url "#{repo_data['url']}"
                    #{credentials(repo_data['credentials'])}
                  }\n\t\t)
                end
    end

    result
  end

  def maven_repo_builder(repo_data)
    "maven {\n#{url_line(repo_data['url'])}\n#{credentials(repo_data)}\n\t}\n\t"
  end

  def credentials(credentials)
    return "" unless credentails?(credentials)

    # do not change indentation
    %(credentials {
              username '#{credentials['username']}'
              password '#{credentials['password']}'
            })
  end

  def credentails?(credentials)
    return false unless credentials.present?
    return false unless credentials["username"].present? && credentials["password"].present?

    true
  end

  def pure_js_dependency?(plugin)
    # this method will return true if the plugin is a pure js plugin,
    # and should not add anything in the gradle files.
    # this covers:
    #   - data source providers
    return true if plugin["type"] == "data_source_provider"

    #   - react-native plugins which don't have native dependencies
    return false unless plugin["react_native"]

    no_npm_dependencies = plugin["npm_dependencies"].nil?
    no_extra_dependencies = plugin["extra_dependencies"].nil?
    no_project_dependencies = plugin["project_dependencies"].nil?

    no_npm_dependencies && no_extra_dependencies && no_project_dependencies
  end

  def skip_gradle_import?(plugin)
    return true if plugin["react_native"]

    plugin["dependency_name"].nil? || plugin["dependency_name"].empty?
  end
end
