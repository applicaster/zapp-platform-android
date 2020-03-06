# frozen_string_literal: true

require "aws-sdk-s3"
require "securerandom"
require "app_build_helper"
require "plugins_helper"
require "dotenv"
require "colorize"
require "workspace_helper"
require "aws_helper"
require "url_helper"
require "system_helper"

desc "Build single bundle"
namespace :single_bundle_aggregator do
  desc "Pull single bundle aggregator repo"
  task pull_repo: :dotenv do
    puts "Building single bundle aggregator".green
    SystemHelper.run "git clone #{WorkspaceHelper.singlebundle_github_repo}"
    FileUtils.cd("#{AppBuildHelper.project_dir}/single-bundle-aggregator")
    SystemHelper.run "git pull origin master"
  end

  desc "aggregate RN plugin to single bundle, and publish to s3"
  task build: :dotenv do
    # find Single Bundle Plugin
    single_bundle_plugin = PluginsHelper.plugin_config(PluginsHelper::SINGLE_BUNDLE_ID)

    next unless single_bundle_plugin

    puts "single bundle plugin found, building...".green
    Rake::Task["single_bundle_aggregator:pull_repo"].invoke
    plugins_json = PluginsHelper.plugins_configuration_json

    # collect all react plugins and add dependencies
    react_modules = plugins_json.map do |config|
      plugin = config["plugin"]
      next unless plugin["react_native"]
      next unless plugin["dependency_name"] && plugin["dependency_version"]

      {
        package: plugin["dependency_name"],
        moduleName: plugin["identifier"],
        version: plugin["dependency_version"],
      }
    end.compact

    File.open(File.join("reactModules.json"), "w+") do |dst|
      dst.write(react_modules.reject(&:empty?).uniq.to_json)
    end

    # add single bundle plugin config to package.json file
    single_bundle_plugin_config = single_bundle_plugin["configuration_json"]
    PluginsHelper.add_package_json_dependencies(single_bundle_plugin_config, "package.json")

    Rake::Task["single_bundle_aggregator:create_bundle"].invoke
    versions_md5 = Digest::MD5.hexdigest(single_bundle_plugin_config.values.join("&"))
    Rake::Task["single_bundle_aggregator:publish"].invoke(versions_md5)
    FileUtils.cd(AppBuildHelper.project_dir)
  end

  desc "create JS bundle"
  task create_bundle: :dotenv do
    SystemHelper.run "mkdir android/build"

    puts "yarn install".green
    SystemHelper.run "yarn"

    puts "aggregate bundles".green
    SystemHelper.run "yarn aggregate:bundles"

    puts "build android bundle".green
    SystemHelper.run "node_modules/.bin/react-native bundle --platform android --dev false" \
      " --entry-file index.js --bundle-output android/build/index.android.bundle.js"
  end

  desc "Upload single bundle to S3"
  task :publish, :bundle_uuid do |_task, args|
    bundle_path = "android/build/index.android.bundle.js"
    puts "bundle_path v.#{bundle_path}".green
    upload_path = UrlHelper.rn_single_bundle_remote_path(args[:bundle_uuid])

    puts "Start uploading single bundle to s3 for: #{upload_path}"

    raise "AWS credentials missing".red unless AwsHelper.aws_credentials_exist?

    s3 = S3Helper.resource_from_env_vars
    obj = s3.bucket(ENV["S3_BUCKET_NAME"]).object(upload_path)
    obj.upload_file(bundle_path, acl: "public-read")
    puts "Finished uploading apk to S3."
  end
end
