# frozen_string_literal: true

require "dotenv"
require "colorize"
require "active_support/core_ext/string"
require "system_helper"
require "plugins_helper"

desc "Generate quickbrick's React Native environment and copy js bundle to assets folder"
namespace :quickbrick do
  task create: :dotenv do
    # Take version from ENV, fallback to version from .env file
    version_id = ENV["VERSION"].presence || ENV["version_id"]

    puts "run zapplicaster-cli prepare".cyan
    SystemHelper.run("yarn quick-brick:prepare #{version_id}")

    build_rn_bundle unless skip_rn_bundle_build

    PluginsHelper.add_react_native_dependency
  end
end

def build_rn_bundle
  skip_bundle_minification =
    ENV["SKIP_BUNDLE_MINIFICATION"].presence || ENV["skip_bundle_minification"]

  build_script = "yarn quick-brick:build"
  build_script = "#{build_script}:debug" if skip_bundle_minification

  puts "generate js bundle for quickbrick and copy to assets folder".cyan
  puts "Bundle is #{skip_bundle_minification ? 'not ' : ''}minified"
  SystemHelper.run(build_script)
end

def skip_rn_bundle_build
  ENV["REACT_NATIVE_PACKAGER_ROOT"].presence || ENV["react_native_packager_root"].presence
end
