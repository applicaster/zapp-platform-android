# frozen_string_literal: true

require "spec_helper"
require "pry"

RSpec.describe PluginsHelper do
  before do
    mock_plugins_json_file
    clean_build_gradle_env_vars
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
  end

  after(:all) do
    cleanup
  end

  describe "pure_js_dependency?" do
    context "when plugin is a data source provider" do
      it "returns true" do
        expect(subject.pure_js_dependency?(data_source_provider)).to be true
      end
    end

    context "when plugin is a react native plugin without native dependencies" do
      it "returns true" do
        expect(subject.pure_js_dependency?(rn_plugin_without_native_dependencies)).to be true
      end
    end

    context "when plugin is a native android plugin" do
      it "returns false" do
        expect(subject.pure_js_dependency?(native_plugin)).to be false
      end
    end

    context "when plugin is a react native plugin with extra dependencies" do
      it "returns false" do
        expect(subject.pure_js_dependency?(react_native_plugin_with_extra_dependencies)).to be false
      end
    end

    context "when plugin is a react native plugin with project dependencies" do
      it "returns false" do
        expect(subject.pure_js_dependency?(react_native_plugin_with_project_dependencies))
          .to be false
      end
    end
  end

  def plugin_configurations
    plugin_configurations_file = File.read(File.join(Dir.pwd, "plugin_configurations.json"))
    JSON.parse(plugin_configurations_file).map { |p| p["plugin"] }
  end

  def data_source_provider
    plugin_configurations
      .select { |plugin| plugin.try(:[], "type") == "data_source_provider" }
      .first
  end

  def rn_plugin_without_native_dependencies
    plugin_configurations
      .select { |plugin| plugin.try(:[], "name") == "RN plugin no dependencies" }
      .first
  end

  def native_plugin
    plugin_configurations
      .select { |plugin| plugin.try(:[], "name") == "Test1 plugin - android" }
      .first
  end

  def react_native_plugin_with_extra_dependencies
    plugin_configurations
      .select { |plugin| plugin.try(:[], "name") == "RN plugin with Native dependencies" }
      .first
  end

  def react_native_plugin_with_project_dependencies
    plugin_configurations
      .select { |plugin| plugin.try(:[], "name") == "RN plugin with Native dependencies" }
      .first
  end

  def cleanup
    clean_build_gradle_env_vars
    FileUtils.rm(File.join(Dir.pwd, "plugin_configurations.json"))
  end

  def mock_plugins_json_file
    FileUtils.cp(
      File.join(Dir.pwd, "spec/fixtures/files/plugin_configurations.json"),
      AppBuildHelper.project_dir,
    )
  end
end
