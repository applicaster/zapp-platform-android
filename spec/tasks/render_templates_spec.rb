# frozen_string_literal: true

require "spec_helper"

RSpec.describe "render_templates", type: :rake do
  let(:curl) { Curl::Easy }
  let(:template_helper) { double("TemplateHelper") }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)

    stub_request(:get, %r{https://assets-secure.applicaster.com/*.})
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "http://test_remote_configurations.json")
      .to_return(status: 200, body: "", headers: {})

    ENV["quick_brick_enabled"] = "true"
  end

  after(:all) do
    cleanup
  end

  it "has the correct name" do
    expect(subject.name).to eq("render_templates")
  end

  it "downloads keystore" do
    allow_any_instance_of(TemplateHelper).to receive(:render_template)
    expect(curl).to receive(:download).with(ENV["key_store_url"])
    subject.execute
  end

  it "renders app/build.gradle template" do
    allow_any_instance_of(TemplateHelper).to receive(:render_template)

    expect_any_instance_of(TemplateHelper).to receive(:render_template)
      .with("qb_build.gradle.erb", "app/build.gradle")

    subject.execute
  end

  it "renders top level build.gradle template" do
    allow_any_instance_of(TemplateHelper).to receive(:render_template)

    expect_any_instance_of(TemplateHelper).to receive(:render_template)
      .with("qb_top_level_build.gradle.erb", "build.gradle")

    subject.execute
  end

  it "renders gradle-wrapper.properties template" do
    allow_any_instance_of(TemplateHelper).to receive(:render_template)

    expect_any_instance_of(TemplateHelper).to receive(:render_template)
      .with("gradle-wrapper.properties.erb", "gradle/wrapper/gradle-wrapper.properties")

    subject.execute
  end

  it "renders applicaster.properties template" do
    allow_any_instance_of(TemplateHelper).to receive(:render_template)

    expect_any_instance_of(TemplateHelper).to receive(:render_template)
      .with("applicaster.properties.erb", "app/src/main/assets/applicaster.properties")

    subject.execute
  end

  it "renders strings.xml template" do
    allow_any_instance_of(TemplateHelper).to receive(:render_template)

    expect_any_instance_of(TemplateHelper).to receive(:render_template)
      .with("strings.xml.erb", "app/src/main/res/values/strings.xml")

    subject.execute
  end

  it "renders AndroidManifest templates" do
    allow_any_instance_of(TemplateHelper).to receive(:multi_language_supported).and_return false
    allow_any_instance_of(TemplateHelper).to receive(:extra_permissions).and_return nil
    subject.execute

    expect(File.open(android_manifest_fixture_qb).read)
      .to be_equivalent_to(File.open("app/src/main/AndroidManifest.xml").read)
  end

  def cleanup
    FileUtils.rm(File.join(Dir.pwd, "keystore.keystore"))
  end

  def android_manifest_fixture
    File.join(Dir.pwd, "spec/fixtures/files/AndroidManifest.xml")
  end

  def android_manifest_fixture_qb
    File.join(Dir.pwd, "spec/fixtures/files/AndroidManifestQuickBrick.xml")
  end
end
