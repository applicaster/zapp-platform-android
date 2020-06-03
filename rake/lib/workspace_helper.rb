# frozen_string_literal: true

class WorkspaceHelper
  def self.zapp_pipes_packager_github_repo
    "https://github.com/applicaster/zapp-pipes-packager.git"
  end

  def self.gradle_settings_file
    File.join(AppBuildHelper.project_dir, "settings.gradle")
  end

  def self.prod_gradle_settings_file
    File.join(AppBuildHelper.project_dir, "public/files/settings.gradle")
  end

  def self.prod_build_gradle_file
    File.join(AppBuildHelper.project_dir, "public/files/build.gradle")
  end

  def self.app_proguard_rules
    File.join(AppBuildHelper.project_dir, "app/proguard-rules.pro")
  end

  def self.base_app_proguard_rules
    File.join(AppBuildHelper.project_dir, "rake/templates/app_proguard-rules.pro")
  end

  def self.dependency_repos
    %w[applicaster-android-sdk zapp_root]
  end

  def self.applicaster_properties
    File.join(AppBuildHelper.project_dir, "app/src/main/assets/applicaster.properties")
  end

  def self.plugin_configuration
    File.join(AppBuildHelper.project_dir, "plugin_configurations.json")
  end

  def self.singlebundle_github_repo
    "https://github.com/applicaster/single-bundle-aggregator.git"
  end

  def self.build_gradle_erb
    quickbrick? ? "qb_build.gradle.erb" : "build.gradle.erb"
  end

  def self.top_level_build_gradle_erb
    quickbrick? ? "qb_top_level_build.gradle.erb" : "top_level_build.gradle.erb"
  end

  def self.quickbrick?
    ENV["quick_brick_enabled"] == "true"
  end

  def self.rounded_icon_exists?
    Dir.glob("app/src/main/res/mipmap-*").any? do |dir|
      File.exist?("#{dir}/ic_launcher_foreground.png")
    end
  end
end
