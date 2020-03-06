# frozen_string_literal: true

require "spec_helper"

RSpec.describe "build_assets_library", type: :rake do
  let(:curl) { Curl::Easy }
  let(:template_helper) { double("TemplateHelper") }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
    allow(Zip::File).to receive(:open).and_return true

    stub_request(:get, %r{http://assets-production.applicaster.com/.*})
      .to_return(status: 200, body: "", headers: {})
  end

  after(:all) do
    cleanup
  end

  it "has the correct name" do
    expect(subject.name).to eq("build_assets_library")
  end

  context "when assets_url exists" do
    it "downloads assets zip" do
      expect(curl).to receive(:download)
        .with(ENV["assets_url"], %r{\/tmp\/assets_\d+.zip})

      subject.execute
    end

    it "unzip the download zip file to the temp dir" do
      expect(Zip::File).to receive(:open)
        .with(%r{\/tmp\/assets_\d+.zip})

      subject.execute
    end
  end

  def cleanup
    assets_dir = File.join(Dir.pwd, "assets.zip")
    FileUtils.rm(assets_dir) if File.file?(assets_dir)
  end
end
