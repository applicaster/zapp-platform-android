# frozen_string_literal: true

require "spec_helper"

RSpec.describe "copy_firebase_configuration", type: :rake do
  let(:curl) { Curl::Easy }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
    allow(FileUtils).to receive(:cd)

    stub_request(:get, %r{http://assets-production.applicaster.com/.*})
      .to_return(status: 200, body: "", headers: {})
  end

  it "has the correct name" do
    expect(subject.name).to eq("copy_firebase_configuration")
  end

  context "with firebase_configuration_url env set" do
    before do
      ENV["firebase_configuration_url"] = "http://example.com/google-services.json"
      allow(File).to receive(:exist?)
        .with("#{AppBuildHelper.project_dir}/styles.json")
        .and_return false

      allow(curl).to receive(:download).with(ENV["firebase_configuration_url"])
    end

    after do
      ENV["firebase_configuration_url"] = nil
    end

    it "downloads firebase configuration to app dir" do
      expect(FileUtils).to receive(:cd).with(File.join(Dir.pwd, "app"))
      expect(curl).to receive(:download).with(ENV["firebase_configuration_url"])

      subject.execute
    end
  end

  context "without firebase_configuration_url env set" do
    before do
      ENV["firebase_configuration_url"] = nil
    end

    it "does nothing" do
      expect(curl).to_not receive(:download).with(ENV["firebase_configuration_url"])

      subject.execute
    end
  end
end
