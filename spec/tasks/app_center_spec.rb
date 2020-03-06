# frozen_string_literal: true

require "spec_helper"
require "app_center_helper"

RSpec.describe "app_center:prepare_app_data", type: :rake do
  let(:app_name) { "test_app" }
  let(:curl) { Curl::Easy }

  before do
    clean_enviorment
    Rake::Task["app_center:prepare_app_data"].reenable
    ENV["ZAPP_TOKEN"] = "1234"
    ENV["APPCENTER_OWNER_NAME"] = "TEST_APPCENTER_OWNER_NAME"
  end

  it "has the correct name" do
    expect(subject.name).to eq("app_center:prepare_app_data")
  end

  context "When app exists on App Center" do
    before do
      get_app_api = "https://api.appcenter.ms/v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/"\
        "android-bundle_identifier"
      app_body = { app_secret: "app_secret_1", name: "app_name_1", is_public: true }.to_json
      stub_curl_request(get_app_api, app_body)

      get_group_api = "https://api.appcenter.ms/v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/"\
        "app_name_1/distribution_groups"
      group_body = [{ app_secret: "app_secret_1", name: "app_group_1", is_public: true }].to_json
      stub_curl_request(get_group_api, group_body)
    end

    it "outputs the app_data.env" do
      invoke_prepare_app_data
      expect(File.open("spec/fixtures/files/app_data_1.env").read)
        .to eq(File.open("app_data.env").read)
    end
  end

  context "when app does not exist on app center" do
    before do
      get_app_api = "https://api.appcenter.ms/v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}/"\
        "android-bundle_identifier"
      app_body_2 = { name: "app_name_2", is_public: true }.to_json
      stub_curl_request(get_app_api, app_body_2)

      get_group_api = "https://api.appcenter.ms/v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}"\
        "/app_name_2/distribution_groups"
      group_body_2 = [{ app_secret: "app_secret_2", name: "app_group_2", is_public: true }].to_json
      stub_curl_request(get_group_api, group_body_2)
    end

    context "and App found hockeyapp-appcenter mapping file" do
      before do
        mapping_api = "https://assets-production.applicaster.com/zapp/tmp/appcenter/android/"\
          "hockeyapp_appcenter_mapping.json"
        mapping_body = [{
          bundle_identifier: "bundle_identifier",
          hockey_app_public_identifier: "app_name_2",
          appcenter_app_secret: "app_secret_2",
          appcenter_app_name: "app_name_2",
          platform: "android",
        }].to_json
        stub_curl_request(mapping_api, mapping_body)
      end

      it "Outputs the app_data.env" do
        invoke_prepare_app_data
        expect(File.open("spec/fixtures/files/app_data_2.env").read)
          .to eq(File.open("app_data.env").read)
      end
    end

    context "and app does not exists on local mapping file" do
      before do
        mapping_api = "https://assets-production.applicaster.com/zapp/tmp/"\
          "appcenter/android/hockeyapp_appcenter_mapping.json"
        mapping_body = "{}"
        stub_curl_request(mapping_api, mapping_body)

        new_app_api = "https://api.appcenter.ms/v0.1/orgs/#{ENV['APPCENTER_OWNER_NAME']}/apps"
        new_app_body = { app_secret: "app_secret_3", name: "app_name_3", is_public: true }.to_json
        stub_curl_request(new_app_api, new_app_body)

        group_body = [{ app_secret: "app_secret_3", name: "app_group_3", is_public: true }].to_json
        get_group_api = "https://api.appcenter.ms/v0.1/apps/#{ENV['APPCENTER_OWNER_NAME']}"\
          "/app_name_3/distribution_groups"
        stub_curl_request(get_group_api, group_body)
      end

      it "outputs the app_data.env" do
        invoke_prepare_app_data
        expect(File.open("spec/fixtures/files/app_data_3.env").read)
          .to eq(File.open("app_data.env").read)
      end
    end
  end

  def invoke_prepare_app_data
    Rake::Task["app_center:prepare_app_data"].invoke("bundle_identifier")
  end

  def stub_curl_request(api, body)
    stub_request(:any, api)
      .to_return(status: 200, body: body, headers: {})
  end

  def clean_enviorment
    File.delete("app_data.env") if File.exist? "app_data.env"
  end
end
