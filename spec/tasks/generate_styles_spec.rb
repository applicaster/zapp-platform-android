# frozen_string_literal: true

require "spec_helper"

RSpec.describe "generate_styles", type: :rake do
  let(:curl) { Curl::Easy }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)

    stub_request(:get, %r{http://assets-production.applicaster.com/.*})
      .to_return(status: 200, body: "", headers: {})
  end

  after(:all) do
    cleanup
  end

  it "has the correct name" do
    expect(subject.name).to eq("generate_styles")
  end

  context "when styles.json is missing" do
    before do
      allow(File).to receive(:exist?)
        .with("#{AppBuildHelper.project_dir}/styles.json")
        .and_return false

      allow(curl).to receive(:download).with("#{ENV['fonts_url']}/Roboto-regular.ttf")
    end

    it "downloads styles.json" do
      expect(curl).to receive(:download).with(ENV["styles_url"])
      subject.execute
    end
  end

  before do
    mock_styles_json_file
    ENV["flavor"] = "mobile"
    allow(curl).to receive(:download).with(ENV["styles_url"])
  end

  it "generates smartphone colors" do
    subject.execute

    expect(
      FileUtils.identical?(File.join(Dir.pwd, "app/src/main/res/values/colors.xml"), colors_xml),
    ).to eq true
  end

  it "generates smartphone styles" do
    subject.execute

    expect(
      FileUtils.identical?(
        File.join(Dir.pwd, "app/src/main/res/values/app_styles.xml"), styles_xml
      ),
    ).to eq true
  end

  it "generates smartphone dimens" do
    subject.execute

    expect(
      FileUtils.identical?(
        File.join(Dir.pwd, "app/src/main/res/values/app_dimens.xml"), dimens_xml
      ),
    ).to eq true
  end

  it "generates tablet colors" do
    subject.execute

    expect(
      FileUtils.identical?(
        File.join(Dir.pwd, "app/src/main/res/values-sw600dp/colors.xml"),
        colors_xml,
      ),
    ).to eq true
  end

  it "generates tablet styles" do
    subject.execute

    expect(
      FileUtils.identical?(
        File.join(Dir.pwd, "app/src/main/res/values-sw600dp/app_styles.xml"),
        styles_xml,
      ),
    ).to eq true
  end

  it "generates tablet dimens" do
    subject.execute

    expect(
      FileUtils.identical?(
        File.join(Dir.pwd, "app/src/main/res/values-sw600dp/app_dimens.xml"),
        dimens_xml,
      ),
    ).to eq true
  end

  context "when device target is universal" do
    before do
      mock_styles_json_file
      allow(curl).to receive(:download).with(ENV["styles_url"])
    end

    it "generates styles" do
      subject.execute

      expect(
        FileUtils.identical?(
          File.join(Dir.pwd, "app/src/main/res/values/app_styles.xml"), universal_size_style_xml
        ),
      ).to eq true
    end
  end

  context "when device flavor is TV" do
    before do
      mock_styles_json_file
      ENV["flavor"] = "tv"
      allow(curl).to receive(:download).with(ENV["styles_url"])
    end

    it "generates styles" do
      subject.execute

      expect(
        FileUtils.identical?(
          File.join(Dir.pwd, "app/src/main/res/values/app_styles.xml"), styles_tv
        ),
      ).to eq true
    end
  end

  def cleanup
    FileUtils.rm(File.join(Dir.pwd, "styles.json"))
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/res/values/colors.xml"))
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/res/values/app_styles.xml"))
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/res/values/app_dimens.xml"))
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/res/values-sw600dp/colors.xml"))
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/res/values-sw600dp/app_styles.xml"))
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/res/values-sw600dp/app_dimens.xml"))
  end

  def colors_xml
    File.join(Dir.pwd, "spec/fixtures/files/colors.xml")
  end

  def styles_xml
    File.join(Dir.pwd, "spec/fixtures/files/styles.xml")
  end

  def styles_tv
    File.join(Dir.pwd, "spec/fixtures/files/styles_tv.xml")
  end

  def dimens_xml
    File.join(Dir.pwd, "spec/fixtures/files/dimens.xml")
  end

  def universal_size_style_xml
    File.join(Dir.pwd, "spec/fixtures/files/universal_styles.xml")
  end

  def mock_styles_json_file
    FileUtils.cp(File.join(Dir.pwd, "spec/fixtures/files/styles.json"), AppBuildHelper.project_dir)
  end

  def mock_universal_styles_json_file
    FileUtils.cp(
      File.join(Dir.pwd, "spec/fixtures/files/universal_styles.json"),
      AppBuildHelper.project_dir,
    )
  end
end
