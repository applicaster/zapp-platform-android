# frozen_string_literal: true

require "faraday"

desc "Notify Zapp"
namespace :zapp do
  task(
    :notify_zapp_build,
    :app_version_id,
    :build_status,
    :debug_artifact_install_url,
    :debug_artifact_download_url,
    :debug_appcenter_release_id,
    :debug_appcenter_app_name,
    :debug_artifact_publish_time,
    :release_artifact_install_url,
    :release_artifact_download_url,
    :release_appcenter_release_id,
    :release_appcenter_app_name,
    :release_artifact_publish_time,
    :artifact_public_identifier,
    :build_url,
    :build_num,
    :reponame,
    :vcs_revision,
    :branch,
    :zapp_token,
  ) do |_task, args|
    next unless ENV["triggered_by"] == "zapp"

    connection = Faraday.new(url: "https://zapp.applicaster.com") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true do |logger|
        logger.filter(/(access_token=)(\w+)/, "\1[REMOVED]")
      end
      faraday.adapter Faraday.default_adapter
    end

    build_params = {
      app_version_id: args[:app_version_id],
      build_status: args[:build_status],
      debug_download_link: args[:debug_artifact_download_url],
      release_download_link: args[:release_artifact_download_url],
      debug_installation_link: args[:debug_artifact_install_url],
      release_installation_link: args[:release_artifact_install_url],
      debug_appcenter_release_id: args[:debug_appcenter_release_id],
      release_appcenter_release_id: args[:release_appcenter_release_id],
      debug_appcenter_app_name: args[:debug_appcenter_app_name],
      release_appcenter_app_name: args[:release_appcenter_app_name],
      debug_app_published_time: args[:debug_artifact_publish_time],
      release_app_published_time: args[:release_artifact_publish_time],
      distribution_public_identifier: args[:artifact_public_identifier],
      build_url: args[:build_url],
      build_num: args[:build_num],
      reponame: args[:reponame],
      vcs_revision: args[:vcs_revision],
      branch: args[:branch],
    }.reject { |_k, v| v.nil? || v.to_s.empty? }

    params = {
      build: build_params,
      access_token: ENV["ZAPP_TOKEN"] || args[:zapp_token],
    }

    response = connection.put("api/v1/ci_builds/#{args[:app_version_id]}", params)
    raise "Failed to update version on Zapp with error #{response.status}" unless response.success?

    puts "Version with id #{args[:app_version_id]} was updated!"
  end
end
