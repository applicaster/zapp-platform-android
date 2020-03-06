# frozen_string_literal: true

require "json"
require "open-uri"
require "uri"
require "active_support/core_ext/string"
require "app_center_helper"

desc "Prepare app data for App Center distribution"
namespace :app_center do
  task(
    :prepare_app_data, :bundle_identifier
  ) do |_task, args|
    set_app_data(args[:bundle_identifier], "android")
  end
end

def set_app_data(bundle_identifier, platform)
  app = fetch_app(bundle_identifier, platform)

  return export_app(bundle_identifier, app) if app["app_secret"]

  # check against hockeyapp-appcenter mapping
  puts("App with name '#{platform}-#{bundle_identifier}' not found in app-center,
    checking against hockeyapp-appcenter mapping file")

  mapping_app = fetch_app_details_from_mapping(bundle_identifier, platform)
  return export_mapping_app(bundle_identifier, mapping_app) if mapping_app

  new_app = create_new_app(bundle_identifier, platform)
  export_app(bundle_identifier, new_app)
end

def fetch_app(bundle_identifier, platform)
  puts "Trying to find app on APP Center"

  app_name = "#{platform}-#{bundle_identifier}"
  AppCenterHelper.curl_get_app(app_name)
end

def fetch_app_details_from_mapping(bundle_identifier, platform)
  puts "Trying to find app on mapping file"

  mapping_data = AppCenterHelper.curl_get_mapping
  mapping_data.select { |h| mapped_identifier?(h, bundle_identifier, platform) }.first
end

def mapped_identifier?(h, bundle_identifier, platform)
  h["bundle_identifier"] == bundle_identifier && h["platform"] == platform
end

def create_new_app(bundle_identifier, platform)
  puts("App not found in hockeyapp-appcenter mapping file, creating new app on app-center")

  app_name = "#{platform}-#{bundle_identifier}"
  AppCenterHelper.curl_post_new_app(app_name)
end

def distribution_group(bundle_identifier, app_name)
  groups = fetch_app_distribution_groups(app_name)
  public_group = groups.select { |h| h["is_public"] == true }.first

  return app_group(bundle_identifier, public_group["name"]) if public_group.present?

  new_public_group = create_new_public_distribution_group(app_name)
  return app_group(bundle_identifier, new_public_group["name"]) if new_public_group.present?

  raise("Unable to create app distribution group")
end

def create_new_public_distribution_group(app_name)
  AppCenterHelper.curl_post_app_group(app_name)
end

def fetch_app_distribution_groups(app_name)
  AppCenterHelper.curl_get_app_group(app_name)
end

def export_app(bundle_identifier, app)
  app_center_group = distribution_group(bundle_identifier, app["name"])
  store_results(app["name"], app["app_secret"], app_center_group)
end

def export_mapping_app(bundle_identifier, app)
  app_center_group = distribution_group(bundle_identifier, app["appcenter_app_name"])
  store_results(app["appcenter_app_name"], app["appcenter_app_secret"], app_center_group)
end

def app_group(bundle_identifier, group_name)
  puts("Saving app data for bundle: #{bundle_identifier}, app_group: #{group_name}")
  group_name
end

def store_results(app_center_name, app_center_secret, app_center_group)
  File.open("app_data.env", "ab") do |file|
    file.puts("export app_center_app_name=\"#{app_center_name}\"")
    file.puts("export app_center_secret=\"#{app_center_secret}\"")
    file.puts("export app_group=\"#{app_center_group}\"")
  end
end
