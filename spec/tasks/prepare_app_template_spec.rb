# frozen_string_literal: true

require "spec_helper"

RSpec.describe "prepare_app_template", type: :rake do
  let(:templates_dir) { AppBuildHelper.template_dir("template1", false) }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
  end

  it "has the correct name" do
    expect(subject.name).to eq("prepare_app_template")
  end

  it "copies the assets folder" do
    allow(FileUtils).to receive(:cp_r)
      .with(Dir["#{templates_dir}/res/*"], AppBuildHelper.resources_dir.to_s)
      .and_return true

    expect(FileUtils).to receive(:cp_r)
      .with(Dir["#{templates_dir}/assets/*"], AppBuildHelper.assets_dir.to_s)

    subject.execute
  end

  it "copies the resources folder" do
    allow(FileUtils).to receive(:cp_r)
      .with(Dir["#{templates_dir}/assets/*"], AppBuildHelper.assets_dir.to_s)

    expect(FileUtils).to receive(:cp_r)
      .with(Dir["#{templates_dir}/res/*"], AppBuildHelper.resources_dir.to_s)
      .and_return true

    subject.execute
  end
end
