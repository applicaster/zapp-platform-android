# frozen_string_literal: true

require "fileutils"
require "dotenv"
require "dotenv/tasks"
require "colorize"
require "active_support/core_ext/string"
require "plugins_helper"

desc "Downloading plugins configuration"
task download_plugins_configuration: :dotenv do
  puts "no plugins configured".green unless PluginsHelper.plugins_configuration_json
end
