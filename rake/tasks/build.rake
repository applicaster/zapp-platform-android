# frozen_string_literal: true

require "fileutils"
require "system_helper"
require "template_helper"
require "app_build_helper"
require "json"
require "builder"
require "dotenv"
require "dotenv/tasks"
require "versionomy"
require "colorize"
require "active_support/core_ext/string"
require "curb"
require "zip"
require "pry"

desc "submodule update"
task submodule_update: :dotenv do
  system("git submodule update --init --recursive")
end

desc "Generate build files"
task render_templates: :dotenv do
  puts "Downloading .keystore file...".yellow

  Curl::Easy.download(ENV["key_store_url"]) if ENV["key_store_url"].present?

  template_helper = TemplateHelper.new

  puts "Generating top level build.gradle file...".green
  template_helper.render_template(WorkspaceHelper.top_level_build_gradle_erb, "build.gradle")

  if WorkspaceHelper.quickbrick?
    template_helper.render_template(
      "AndroidManifestQuickBrick.xml.erb",
      "app/src/main/AndroidManifest.xml",
    )

    template_helper.render_template(
      "AndroidManifestQuickBrickGoogle.xml.erb",
      "app/src/mobileGoogle/AndroidManifest.xml",
    )

    template_helper.render_template(
      "AndroidManifestTvQuickBrick.xml.erb",
      "app/src/tvGoogle/AndroidManifest.xml",
    )
  end

  template_helper.render_template(WorkspaceHelper.build_gradle_erb, "app/build.gradle")

  template_helper.render_template(
    "gradle-wrapper.properties.erb",
    "gradle/wrapper/gradle-wrapper.properties",
  )

  puts "Generating package.json file...".green
  template_helper.render_template("package.json.erb", "package.json")

  puts "Generating applicaster.properties file...".green
  template_helper.render_template(
    "applicaster.properties.erb",
    "app/src/main/assets/applicaster.properties",
  )

  puts "Update strings.xml...".cyan
  template_helper.render_template(
    "strings.xml.erb",
    "app/src/main/res/values/strings.xml",
  )
end

desc "Copy static files"
task copy_static_files: :dotenv do
  puts "add debug security config xml...".yellow
  FileUtils.cp(
    "rake/static_files/network_security_config.xml",
    "app/src/main/res/xml/network_security_config.xml",
  )

  if WorkspaceHelper.rounded_icon_exists?
    puts "Rounded icon found, adding drawable...".cyan
    FileUtils.mkdir_p "app/src/main/res/mipmap-anydpi-v26/"
    FileUtils.cp(
      "rake/static_files/ic_launcher_round.xml",
      "app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml",
    )
  end
end

desc "Build app assets library"
task build_assets_library: :dotenv do
  AppBuildHelper.expand_assets(ENV["assets_url"])
end

desc "Prepare app template"
task prepare_app_template: :dotenv do
  if ENV["template"].present?
    puts "Selecting #{ENV['template']}, RTL=#{ENV['rtl']}".green
    templates_dir = AppBuildHelper.template_dir(ENV["template"], ENV["rtl"])

    puts "copying modular properties files from #{templates_dir}".cyan
    FileUtils.cp_r(Dir["#{templates_dir}/assets/*"], AppBuildHelper.assets_dir.to_s)

    puts "copying resources dir from #{templates_dir}".cyan
    FileUtils.cp_r(Dir["#{templates_dir}/res/*"], AppBuildHelper.resources_dir.to_s)
  else
    puts "Using default template (template 1)".green
  end
end

desc "Copy fonts"
task copy_fonts: :dotenv do
  fonts = JSON.parse(ENV["fonts"].to_s)

  if ENV["fonts_url"].present?
    puts "Downloading fonts...".yellow
    if ENV["fonts"].present?
      fonts.each do |font|
        FileUtils.cd(AppBuildHelper.global_fonts_dir.to_s)
        Curl::Easy.download("#{ENV['fonts_url']}/#{font}")
        FileUtils.cd(AppBuildHelper.project_dir.to_s)
      end
    end
  end

  puts "copying fonts".green
  fonts.each do |font|
    file = "#{AppBuildHelper.global_fonts_dir}/#{font}"

    FileUtils.cp(Dir[file], AppBuildHelper.fonts_dir.to_s) if file
  end
end

desc "Generate styles"
task generate_styles: :dotenv do
  if ENV["styles_url"].present?
    puts "Generating styles...".green

    puts "Downloading styles.json from #{ENV['styles_url']}".yellow
    Curl::Easy.download(ENV["styles_url"])

    puts "parsing styles...".cyan
    styles_json = JSON.parse(File.read("#{AppBuildHelper.project_dir}/styles.json"))
    squashed_styles = AppBuildHelper.squash_styles_json(styles_json, ENV["flavor"].to_s == "tv")

    squashed_styles.each do |device_target, values|
      # Build colors xml
      color_builder = Builder::XmlMarkup.new(indent: 2)
      color_builder.instruct!

      colors_xml = color_builder.resources do
        values.each do |key, value|
          next unless value
          next unless value["color"]

          color_builder.color(value["color"], name: key)
        end
      end

      # Build dimen xml
      dimen_builder = Builder::XmlMarkup.new(indent: 2)
      dimen_builder.instruct!

      dimens_xml = dimen_builder.resources do
        values.each do |key, value|
          next unless value
          next unless value["dimension"]

          dimen_builder.dimen("#{value['dimension']}dp", name: key)
        end
      end

      # Build styles xml
      styles_builder = Builder::XmlMarkup.new(indent: 2)
      styles_builder.instruct!

      styles_xml = styles_builder.resources do
        values.each do |key, value|
          next unless value
          next unless value["font"]

          styles_builder.style(name: AppBuildHelper.camelize(key)) do
            styles_builder.item(value["font"], name: "customtypeface")
            styles_builder.item("#{value['font_size']}dp", name: "android:textSize")
            styles_builder.item("@color/#{key}", name: "android:textColor")
          end
        end
      end

      values_folder = if device_target == "tablet"
                        AppBuildHelper.tablet_values_folder
                      else
                        AppBuildHelper.smartphone_values_folder
                      end

      puts "creating #{device_target} colors.xml...".cyan

      File.open("#{values_folder}/colors.xml", "wb") do |file|
        file.write(colors_xml)
      end

      puts "creating #{device_target} styles.xml...".cyan

      File.open("#{values_folder}/app_styles.xml", "wb") do |file|
        file.write(styles_xml)
      end

      puts "creating #{device_target} app_dimens.xml...".cyan

      File.open("#{values_folder}/app_dimens.xml", "wb") do |file|
        file.write(dimens_xml)
      end
    end
  else
    puts "Using default styles".green
  end
end

desc "Install NPM packages"
task install_npm_packages: :dotenv do
  puts "Running npm install...".green
  SystemHelper.run("npm install") # if npm install fails, stop the whole build
end

desc "Run NPM scripts"
task run_npm_scripts: :dotenv do
  if ENV["quick_brick_enabled"].to_s == "true"
    Rake::Task["quickbrick:create"].invoke
  else
    puts "skipping running npm scripts".yellow
  end
end

desc "Build app"
task build_app: :dotenv do
  Rake::Task[:clean].invoke
  Rake::Task[:submodule_update].invoke
  Rake::Task[:copy_firebase_configuration].invoke
  Rake::Task[:prepare_app_template].invoke
  Rake::Task[:generate_styles].invoke
  Rake::Task[:copy_fonts].invoke
  Rake::Task[:build_assets_library].invoke
  Rake::Task[:render_templates].invoke
  Rake::Task[:copy_static_files].invoke
  Rake::Task[:download_plugins_configuration].invoke
  Rake::Task["single_bundle_configuration:setup"].invoke
  Rake::Task[:install_npm_packages].invoke
  Rake::Task[:run_npm_scripts].invoke
  Rake::Task[:generate_plugins].invoke
  Rake::Task[:compose_debug_ribbon].invoke
end

desc "prepare development workspace"
task prepare_workspace: :dotenv do
  Rake::Task[:generate_dotenv].invoke
  Rake::Task[:build_app].invoke
end
