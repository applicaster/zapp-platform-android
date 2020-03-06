# frozen_string_literal: true

require "spec_helper"

RSpec.describe "build_app", type: :rake do
  let(:clean)                           { Rake::Task["clean"] }
  let(:prepare_app_template)            { Rake::Task["prepare_app_template"] }
  let(:generate_styles)                 { Rake::Task["generate_styles"] }
  let(:copy_fonts)                      { Rake::Task["copy_fonts"] }
  let(:render_templates)                { Rake::Task["render_templates"] }
  let(:copy_static_files)               { Rake::Task["copy_static_files"] }
  let(:download_plugins_configuration)  { Rake::Task["download_plugins_configuration"] }
  let(:single_bundle_configuration)     { Rake::Task["single_bundle_configuration:setup"] }
  let(:install_npm_packages)            { Rake::Task["install_npm_packages"] }
  let(:run_npm_scripts)                 { Rake::Task["run_npm_scripts"] }
  let(:generate_plugins)                { Rake::Task["generate_plugins"] }
  let(:build_assets_library)            { Rake::Task["build_assets_library"] }
  let(:compose_debug_ribbon)            { Rake::Task["compose_debug_ribbon"] }
  let(:copy_firebase_configuration)     { Rake::Task["copy_firebase_configuration"] }

  it "has the correct name" do
    expect(subject.name).to eq("build_app")
  end

  it "runs tasks in the correct order" do
    expect(clean).to receive(:invoke).ordered
    expect(copy_firebase_configuration).to receive(:invoke).ordered
    expect(prepare_app_template).to receive(:invoke).ordered
    expect(generate_styles).to receive(:invoke).ordered
    expect(copy_fonts).to receive(:invoke).ordered
    expect(build_assets_library).to receive(:invoke).ordered
    expect(render_templates).to receive(:invoke).ordered
    expect(copy_static_files).to receive(:invoke).ordered
    expect(download_plugins_configuration).to receive(:invoke).ordered
    expect(single_bundle_configuration).to receive(:invoke).ordered
    expect(install_npm_packages).to receive(:invoke).ordered
    expect(run_npm_scripts).to receive(:invoke).ordered
    expect(generate_plugins).to receive(:invoke).ordered
    expect(compose_debug_ribbon).to receive(:invoke).ordered
    subject.execute
  end
end
