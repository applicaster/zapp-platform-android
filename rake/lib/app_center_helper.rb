# frozen_string_literal: true

require "curb"

class AppCenterHelper
  def self.process_response(result, error_message)
    failure = result.blank? || result["statusCode"] == 404
    return JSON.parse(result) unless failure

    raise error_message
  end

  def self.curl_get_app_center(api)
    base = "https://api.appcenter.ms"
    headers = [
      "accept: application/json",
      "Content-Type: application/json",
      "X-API-Token: #{ENV['APPCENTER_API_TOKEN']}",
    ]
    curl_get("#{base}/#{api}", headers)
  end

  def self.curl_post_app_center(api, body)
    base = "https://api.appcenter.ms"

    headers = [
      "accept: application/json",
      "Content-Type: application/json",
      "X-API-Token: #{ENV['APPCENTER_API_TOKEN']}",
    ]

    curl_post("#{base}/#{api}", headers, body)
  end

  def self.curl_get_mapping
    base = "https://assets-production.applicaster.com/zapp/tmp/appcenter/android"
    file_name = "hockeyapp_appcenter_mapping.json"
    headers = [
      "accept: application/json",
      "Content-Type: application/json",
    ]
    response = curl_get("#{base}/#{file_name}", headers)
    process_response(response, "Failed to fetch mapping details")
  end

  def self.curl_get(url, headers)
    instance = Curl::Easy.new(url)
    instance.headers = headers

    instance.verbose = true

    instance.perform

    puts instance.body_str
    instance.body_str
  end

  def self.curl_post(url, headers, body)
    instance = Curl::Easy.new(url)

    instance.headers = headers

    instance.verbose = true

    instance.http_post(body)

    puts instance.body_str
    instance.body_str
  end

  def self.curl_get_app(app_name)
    api = "v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/#{app_name}"

    response = curl_get_app_center(api)
    process_response(response, "Failed to fetch app details")
  end

  def self.curl_get_app_group(app_name)
    api = "v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/#{app_name}/distribution_groups"

    response = curl_get_app_center(api)
    process_response(response, "Failed to fetch app distribution_groups")
  end

  def self.curl_get_app_stores(app_name)
    api = "v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/#{app_name}/distribution_stores"

    response = curl_get_app_center(api)
    process_response(response, "Failed to fetch details for #{app_name}")
  end

  def self.curl_post_new_app(app_name)
    api = "v0.1/orgs/#{ENV['APPCENTER_OWNER_NAME']}/apps"
    body = {
      description: ENV["app_name"],
      release_type: "Beta",
      display_name: ENV["app_name"],
      name: app_name,
      os: "Android", platform: "Java"
    }.to_json

    response = curl_post_app_center(api, body)
    process_response(response, "Failed to create new app")
  end

  def self.curl_post_app_group(app_name)
    api = "v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/#{app_name}/distribution_groups"
    body = {
      name: "All app users",
      is_public: true,
    }.to_json

    response = curl_post_app_center(api, body)
    process_response(response, "Failed to create new app distribution_groups")
  end

  def self.curl_get_service_account_key
    api = ENV["service_account_key_url"]
    headers = [
      "accept: application/json",
      "Content-Type: application/json",
    ]
    response = curl_get(api, headers)
    process_response(response, "Failed to load service_account_api_key.json")
  end
end
