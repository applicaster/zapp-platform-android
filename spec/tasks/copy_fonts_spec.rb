# frozen_string_literal: true

require "spec_helper"

RSpec.describe "copy_fonts", type: :rake do
  let(:curl) { Curl::Easy }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
    allow(FileUtils).to receive(:cd)

    stub_request(:get, %r{(http|https)://assets-(production|secure).applicaster.com/.*})
      .to_return(status: 200, body: "", headers: {})
  end

  after(:all) do
    cleanup
  end

  it "has the correct name" do
    expect(subject.name).to eq("copy_fonts")
  end

  it "downloads custom fonts to global fonts dir" do
    ENV["fonts"] = ["Roboto-Regular.ttf"].to_s

    expect(FileUtils).to receive(:cd).with(File.join(Dir.pwd, "fonts"))
    expect(curl).to receive(:download).with("#{ENV['fonts_url']}/Roboto-Regular.ttf")

    subject.execute
  end

  it "copies fonts from global font dir to assets/fonts dir" do
    ENV["fonts"] = ["Roboto-Regular.ttf"].to_s

    expect(FileUtils).to receive(:cp)
      .with(
        [File.join(Dir.pwd, "fonts/Roboto-Regular.ttf")],
        File.join(Dir.pwd, "app/src/main/assets/fonts"),
      )

    subject.execute
  end

  def cleanup
    FileUtils.rm(File.join(Dir.pwd, "Roboto-Regular.ttf"))
  end
end
