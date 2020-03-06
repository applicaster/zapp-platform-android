# A sample Gemfile
source "https://rubygems.org"

gem "zapp_sdk_tasks", '~> 0.5.0'

gem "rake", "~> 11.0"
gem "pry"
gem "builder", "~> 3.2", ">= 3.2.2"
gem "dotenv", "~>  2.7.5"
gem "colorize"
gem "versionomy"
gem "activesupport", "~> 4.2", ">= 4.2.6"
gem "mini_magick", "~> 4.9.5"
gem "curb"
gem "java-properties"
gem "rubyzip", "~> 1.3.0"

gem "rspec", "~> 3.8.0"
gem "equivalent-xml"
gem "fantaskspec", "~> 1.0.0"
gem "webmock", "~> 3.7.5"
gem "diff_dirs", "~> 0.1.2"
gem "rubocop", "~> 0.76.0", require: false
gem "fastlane", "~> 2.135.2"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
