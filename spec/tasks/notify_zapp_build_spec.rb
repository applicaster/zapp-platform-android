# frozen_string_literal: true

require "spec_helper"

RSpec.describe "zapp:notify_zapp_build", type: :rake do
  before do
    Rake::Task["zapp:notify_zapp_build"].reenable
    ENV["ZAPP_TOKEN"] = "1234"
  end

  it "has the correct name" do
    expect(subject.name).to eq("zapp:notify_zapp_build")
  end

  context "when it's not triggered_by zapp" do
    before do
      ENV["triggered_by"] = "not-zapp"
    end

    it "skips app version update" do
      stub_request(:put, "https://zapp.applicaster.com/api/v1/ci_builds/app-version-id")
      invoke_notify_zapp_build

      assert_not_requested(
        :put,
        "https://zapp.applicaster.com/api/v1/ci_builds/app-version-id",
        times: 1,
      )
    end
  end

  context "when it was triggered_by zapp" do
    before do
      ENV["triggered_by"] = "zapp"
    end

    context "when request fails" do
      before do
        stub_request(:put, "https://zapp.applicaster.com/api/v1/ci_builds/app-version-id")
          .to_return(status: [500, "Internal Server Error"])
      end

      it "throws error exit 1" do
        expect { invoke_notify_zapp_build }
          .to raise_error("Failed to update version on Zapp with error 500")
      end
    end

    it "calls updates zapp app version" do
      stub_request(:put, "https://zapp.applicaster.com/api/v1/ci_builds/app-version-id")
        .to_return(status: [200, "success"])

      invoke_notify_zapp_build

      assert_requested(
        :put,
        "https://zapp.applicaster.com/api/v1/ci_builds/app-version-id",
        times: 1,
      )
    end

    # rubocop:disable Metrics/MethodLength
    def request_params
      {
        build: {
          app_version_id: "app-version-id",
          build_status: "success",
          debug_install_link: "debug-install-url",
          debug_download_link: "debug-download-url",
          debug_appcenter_release_id: 1234,
          debug_appcenter_app_name: "com.applicaster.mybundle.debug",
          debug_app_published_time: "2018-03-06T20:35:49Z",
          release_install_link: "release-install-url",
          release_download_link: "release-download-url",
          release_appcenter_release_id: 4321,
          release_appcenter_app_name: "Analytics4",
          release_app_published_time: "2018-03-06T20:35:49Z",
          distribution_public_identifier: "public-id",
          build_url: "build-url",
          build_num: 1,
          reponame: "Zapp-Android",
          vcs_revision: "12345",
          branch: "release",
        },
        access_token: "1234",
      }
    end
    # rubocop:enable Metrics/MethodLength
  end

  def invoke_notify_zapp_build
    Rake::Task["zapp:notify_zapp_build"].invoke(
      "app-version-id",
      "success",
      "debug-install-url",
      "debug-download-url",
      1234,
      "2018-03-06T20:35:49Z",
      "release-install-url",
      "release-download-url",
      4321,
      "2018-03-06T20:35:49Z",
      "public-id",
      "build-url",
      1,
      "Zapp-Android",
      "12345",
      "release",
    )
  end
end
