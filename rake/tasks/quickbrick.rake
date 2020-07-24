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

    build_rn_bundle if should_build_rn_bundle

    PluginsHelper.add_react_native_dependency
  end
end

def build_rn_bundle(minified = true)
  build_script = "yarn quick-brick:build"
  build_script << "debug" unless minified

  puts "generate js bundle for quickbrick and copy to assets folder".cyan
  puts "Bundle is #{minified ? '' : 'not '}minified"
  SystemHelper.run(build_script)
end

def should_build_rn_bundle
  # this is where we can check the flag from build params to know if we
  # should build the rn bundle or not
  true
end
