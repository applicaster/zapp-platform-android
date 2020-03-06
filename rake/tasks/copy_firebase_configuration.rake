# frozen_string_literal: true

require "fileutils"
require "dotenv"
require "dotenv/tasks"
require "colorize"
require "workspace_helper"

desc "Copy Firebase configuration"
task copy_firebase_configuration: :dotenv do
  url = ENV["firebase_configuration_url"]
  if url.present?
    puts "Downloading Firebase configuration...from #{url}".green
    app_dir = AppBuildHelper.app_dir.to_s
    proj_dir = AppBuildHelper.project_dir.to_s
    FileUtils.cd(app_dir)
    Curl::Easy.download(url)
    FileUtils.cd(proj_dir)
  else
    puts "unable to download firebase_configuration_url from #{url}".red
  end
end
