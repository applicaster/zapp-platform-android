# frozen_string_literal: true

require "spec_helper"

RSpec.describe TemplateHelper do
  let(:curl) { Curl::Easy }

  before do
    clean_build_gradle_env_vars
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
  end

  after(:all) do
    cleanup
  end

  describe "multi_language_supported" do
    context "when remote_configurations_url environment var is empty" do
      before do
        ENV["remote_configurations_url"] = ""
      end

      it "returns false" do
        expect(subject.send(:multi_language_supported)).to eq false
      end
    end

    context "when remote_configurations_url exists" do
      before do
        mock_remote_configurations_json_file
        ENV["remote_configurations_url"] = "http://test_remote_configurations.json"
      end

      it "down remote_configurations.json" do
        expect(curl).to receive(:download).with(ENV["remote_configurations_url"])
        subject.send(:multi_language_supported)
      end
    end

    context "when remote_configurations json has more than one language" do
      before do
        mock_remote_configurations_json_file
        ENV["remote_configurations_url"] = "http://test_remote_configurations.json"
        allow(curl).to receive(:download).with(ENV["remote_configurations_url"])
      end

      it "returns true" do
        expect(subject.send(:multi_language_supported)).to eq true
      end
    end

    context "when remote_configurations json has one language" do
      before do
        mock_remote_configurations_json_file
        ENV["remote_configurations_url"] = "http://test_remote_configurations.json"
        allow(curl).to receive(:download).with(ENV["remote_configurations_url"])

        allow(File).to receive(:read)
          .with("#{AppBuildHelper.project_dir}/remote_configurations.json")
          .and_return({ localizations: { es: "test_url.com" } }.to_json)
      end

      it "returns false" do
        expect(subject.send(:multi_language_supported)).to eq false
      end
    end
  end

  describe "extra_permissions" do
    context "when purchase enabled is set" do
      before do
        ENV["purchase_enabled"] = "true"
      end

      it "return billing permission" do
        expect(subject.send(:extra_permissions))
          .to eq "<uses-permission android:name=\"com.android.vending.BILLING\" />\n"
      end
    end

    context "when purchase enabled is false" do
      before do
        ENV["purchase_enabled"] = nil
      end

      it "return billing permission nil" do
        expect(subject.send(:extra_permissions)).to be_nil
      end
    end
  end

  describe "quick_brick_version" do
    context "quick_brick_version env var exists" do
      before do
        ENV["quick_brick_version"] = "3.0.1"
      end

      it "return the env var value" do
        expect(subject.send(:quick_brick_version))
          .to eq "3.0.1"
      end
    end

    context "quick_brick_version env var is set to 'sdk_default'" do
      before do
        ENV["quick_brick_version"] = "sdk_default"
      end

      it "return the SDK_DEFAULT_QB_VERSION" do
        expect(subject.send(:quick_brick_version))
          .to eq subject.class::SDK_DEFAULT_QB_VERSION
      end
    end

    context "quick_brick_version env var is nil" do
      before do
        ENV["quick_brick_version"] = nil
      end

      it "return the SDK_DEFAULT_QB_VERSION" do
        expect(subject.send(:quick_brick_version))
          .to eq subject.class::SDK_DEFAULT_QB_VERSION
      end
    end
  end

  def mock_remote_configurations_json_file
    FileUtils.cp(
      File.join(
        Dir.pwd,
        "spec/fixtures/files/remote_configurations.json",
      ),
      AppBuildHelper.project_dir,
    )
  end

  def cleanup
    clean_build_gradle_env_vars
    FileUtils.rm(File.join(Dir.pwd, "remote_configurations.json"))
  end
end
