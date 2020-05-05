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

    # puts "run zapplicaster-cli prepare".cyan
    # SystemHelper.run("yarn quick-brick:prepare #{version_id}")

    # puts "generate minified js bundle for quickbrick and copy to assets folder".cyan
    # SystemHelper.run("yarn quick-brick:build")

    PluginsHelper.add_react_native_dependency
  end
end
