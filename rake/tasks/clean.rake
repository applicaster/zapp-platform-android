# frozen_string_literal: true

require "fileutils"
require "dotenv"
require "dotenv/tasks"
require "colorize"
require "workspace_helper"
require "pry"

desc "clean workspace"
task clean: :dotenv do
  puts "cleaning Zapp properties and files".green
  FileUtils.rm_rf("app/src/main/res/drawable-hdpi")
  FileUtils.rm_rf("app/src/main/res/drawable-mdpi")
  FileUtils.rm_rf("app/src/main/res/drawable-sw600dp")
  FileUtils.rm_rf("app/src/main/res/drawable-xhdpi")
  FileUtils.rm_rf("app/src/main/res/drawable-xxhdpi")
  FileUtils.rm_rf("app/src/main/res/drawable")

  FileUtils.rm_f("styles.json")
  FileUtils.rm_f("remote_configurations.json")
  FileUtils.rm_f("plugin_configurations.json")
  FileUtils.rm_f("assets.zip")
  FileUtils.rm_f("app/src/main/AndroidManifest.xml")
  FileUtils.rm_f("app/google-services.json")
  FileUtils.rm_f("app/build.gradle")
  FileUtils.rm_f("package.json")
  FileUtils.rm_rf("single-bundle-aggregator")

  FileUtils.cp_r(
    WorkspaceHelper.prod_gradle_settings_file,
    WorkspaceHelper.gradle_settings_file,
    remove_destination: true,
  )

  FileUtils.cp_r(
    WorkspaceHelper.prod_build_gradle_file,
    "build.gradle",
    remove_destination: true,
  )

  FileUtils.cp_r(
    WorkspaceHelper.base_app_proguard_rules,
    WorkspaceHelper.app_proguard_rules,
    remove_destination: true,
  )

  File.delete(
    *Dir.glob("app/src/main/res/**/*").reject { |f| File.directory?(f) || f.end_with?(".keep") },
  )

  File.delete(
    *Dir.glob("app/src/main/assets/**/*").reject do |f|
      File.directory?(f) || f.end_with?(".keep") || f.include?("app/src/main/assets/fonts")
    end,
  )
end
