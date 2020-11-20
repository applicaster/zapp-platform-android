# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
require "erb"
require "dependency_helper"
require "android_manifest_helper"
require "yaml"
require "workspace_helper"

class TemplateHelper
  include DependencyHelper
  include AndroidManifestHelper

  SDK_DEFAULT_QB_VERSION = "4.1.2"

  def render_template(template_path, dst_path)
    helper_binding = binding
    File.open(File.join("rake", "templates", template_path), "r") do |template|
      File.open(dst_path, "w+") do |dst|
        dst.write(ERB.new(template.read, nil, "-").result(helper_binding))
      end
    end
  end

  private

  def min_sdk_version
    [19, ENV["min_sdk_version"].to_i].max
  end

  def app_name
    ENV["app_name"]
  end

  def bundle_identifier
    ENV["bundle_identifier"]
  end

  def version_name
    ENV["version_name"]
  end

  def build_version
    ENV["build_version"]
  end

  def url_scheme_prefix
    ENV["url_scheme_prefix"]
  end

  def fb_app_id
    ENV["fb_app_id"]
  end

  def applicaster2_account_id
    ENV["applicaster2_account_id"]
  end

  def sdk_version
    ENV["sdk_version"]
  end

  def version_id
    ENV["version_id"]
  end

  def app_family_id
    ENV["app_family_id"]
  end

  def bucket_id
    ENV["bucket_id"]
  end

  def rivers_configuration_id
    ENV["rivers_configuration_id"]
  end

  def broadcaster_id
    ENV["broadcaster_id"]
  end

  def api_private_key
    ENV["api_private_key"]
  end

  def google_api_project_number
    ENV["google_api_project_number"]
  end

  def accounts_account_id
    ENV["accounts_account_id"]
  end

  def locale
    ENV["locale"]
  end

  def twitter_key
    ENV["twitter_key"]
  end

  def twitter_secret
    ENV["twitter_secret"]
  end

  def store_password
    ENV["store_password"]
  end

  def key_alias
    ENV["key_alias"]
  end

  def key_password
    ENV["key_password"]
  end

  def key_store_file
    return "dist.keystore" unless ENV["key_store_url"].present?

    File.basename(ENV["key_store_url"])
  end

  def tag
    ENV["tag"]
  end

  def rtl
    ENV["rtl"].to_s == "true"
  end

  def rounded_icon_exists
    WorkspaceHelper.rounded_icon_exists?
  end

  def rounded_icon
    return "android:roundIcon=\"@mipmap\/ic_launcher_round\"" if rounded_icon_exists
  end

  def tablet_portrait
    ENV["support_tablet_portrait_mode"].to_s == "true"
  end

  def google_api_key
    ENV["google_api_key"]
  end

  def plugin_maven_repos
    ENV["plugins_maven_repos_urls"]
  end

  def zapp_pipes_enabled
    ENV["zapp_pipes_enabled"] || false
  end

  def ui_builder_navigation_bar_api
    ENV["ui_builder_navigation_bar_api"] || false
  end

  def ui_builder_root_api
    ENV["ui_builder_root_api"] || false
  end

  def purchase_enabled
    ENV["purchase_enabled"] == "true" || false
  end

  def s3_hostname
    ENV["s3_hostname"]
  end

  def plugins_dependencies
    PluginsHelper.plugins_dependencies
  end

  def project_gradle_dependencies
    PluginsHelper.project_gradle_dependencies
  end

  def project_dependencies_names
    PluginsHelper.project_dependencies_names
  end

  def project_dependencies_paths
    PluginsHelper.project_dependencies_paths
  end

  def plugins_maven_repos
    PluginsHelper.plugins_maven_repos
  end

  def multi_language_supported
    return false unless ENV["remote_configurations_url"].present?

    puts "Downloading remote_configurations.json from #{ENV['remote_configurations_url']}".yellow
    Curl::Easy.download(ENV["remote_configurations_url"])

    remote_configurations = JSON.parse(
      File.read("#{AppBuildHelper.project_dir}/remote_configurations.json"),
    )

    languages = remote_configurations["localizations"]
    return false unless languages

    languages.count > 1
  end

  def extra_permissions
    "<uses-permission android:name=\"com.android.vending.BILLING\" />\n" if purchase_enabled
  end

  def google_services_integrated?
    google_services_file_path = File.join(AppBuildHelper.app_dir.to_s, "google-services.json")
    File.exist?(google_services_file_path)
  end

  def firebase_dependencies
    if google_services_integrated?
      yml_path = File.join(AppBuildHelper.rake_dir.to_s, "config/gradle.yml")
      data = YAML.load_file(yml_path)
      dependencies = data["firebase_dependencies"]
      version = data["firebase_version"]
      dependencies.join("\n\t\t").gsub("@version", version)
    else
      ""
    end
  end

  def additional_configuration
    PluginsHelper.additional_configuration
  end

  def gms_plugin
    google_services_plugin = "apply plugin: 'com.google.gms.google-services'"
    google_services_integrated? ? google_services_plugin : ""
  end

  def strict_version_matcher_plugin
    plugin = "apply plugin: 'com.google.android.gms.strict-version-matcher-plugin'"
    google_services_integrated? ? "" : plugin
  end

  def gms_google_services_classpath
    google_services_classpath = "classpath 'com.google.gms:google-services:4.3.3'"
    google_services_integrated? ? google_services_classpath : ""
  end

  def strict_version_matcher_plugin_classpath
    plugin_classpath = "classpath 'com.google.android.gms:strict-version-matcher-plugin:1.0.3'"
    google_services_integrated? ? "" : plugin_classpath
  end

  def environment_flavor
    ENV["flavor"]
  end

  def environment_store
    ENV["store"]
  end

  def environment_device_target
    ENV["device_target"]
  end

  def quick_brick_enabled
    ENV["quick_brick_enabled"].to_s == "true"
  end

  # Use either provided quick_brick_version from configuration,
  # or the default version set for the current android sdk.
  def quick_brick_version
    return SDK_DEFAULT_QB_VERSION if ENV["quick_brick_version"] == "sdk_default"

    ENV["quick_brick_version"].presence || SDK_DEFAULT_QB_VERSION
  end

  def app_center_secret
    ENV["app_center_secret"] || "debug_app_center_secret"
  end
end
