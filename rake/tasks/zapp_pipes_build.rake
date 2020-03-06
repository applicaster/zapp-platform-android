# frozen_string_literal: true

require "app_build_helper"
require "dotenv"
require "colorize"
require "workspace_helper"

desc "Pull zapp-pipes packager repo"
task pull_repo: :dotenv do
  puts "Building zapp-pipes bundle".green
  system "git clone #{WorkspaceHelper.zapp_pipes_packager_github_repo}"
end

desc "configure zapp-pipes packager repo"
task configure_packager: :dotenv do
  FileUtils.cd("#{AppBuildHelper.project_dir}/zapp-pipes-packager")
  system "git pull origin master"
  checkout_tag_if_present
  system "npm install"
end

task run_packager: :dotenv do
  system "npm run package #{ENV['version_id']}"
  exit_if_build_failed $CHILD_STATUS.exitstatus
  FileUtils.cd(AppBuildHelper.project_dir.to_s)
  FileUtils.rm_rf("zapp-pipes-packager")
  puts "Zapp-pipes Bundle deployed".green
end

desc "Build zapp-pipes bundle"
task build_zapp_pipes: :dotenv do
  Rake::Task[:pull_repo].invoke
  Rake::Task[:configure_packager].invoke
  Rake::Task[:run_packager].invoke
end

def exit_if_build_failed(exit_code)
  return unless exit_code.positive?

  puts "zapp-pipes packager failed with code #{exit_code} ! stopping the build".red
  exit exit_code
end

def checkout_tag_if_present
  if ENV["zapp_pipes_tag"].present?
    system "git fetch --tags"
    system "git checkout #{ENV['zapp_pipes_tag']}"
  else
    system "no zapp_pipes_tag, skipping tag checkout"
  end
end
