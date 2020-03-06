# frozen_string_literal: true

require "fileutils"
require "plugins_helper"
require "dotenv"
require "dotenv/tasks"
require "colorize"
require "active_support/core_ext/string"

desc "Setting up single bundle plugin configuration"
namespace :single_bundle_configuration do
  task setup: :dotenv do
    single_bundle_plugin = PluginsHelper.plugin_config(PluginsHelper::SINGLE_BUNDLE_ID)
    next unless single_bundle_plugin

    PluginsHelper.add_react_native_dependency

    required_package_json_versions =
      single_bundle_plugin["configuration_json"].slice("react", "react-native")

    PluginsHelper.add_package_json_dependencies(required_package_json_versions, "package.json")

    uuid = Digest::MD5.hexdigest(single_bundle_plugin["configuration_json"].values.join("&"))

    open(WorkspaceHelper.applicaster_properties, "a") do |f|
      f.puts "single_bundle_version=#{uuid}"
    end
  end
end
