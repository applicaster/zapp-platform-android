# frozen_string_literal: true

require "spec_helper"

RSpec.describe "generate_plugins", type: :rake do
  let(:curl) { Curl::Easy }

  before do
    allow(AppBuildHelper).to receive(:project_dir).and_return(Dir.pwd)
    allow(Zip::File).to receive(:open).and_return true
    allow_any_instance_of(Kernel).to receive(:system).with(/npm install -S .*/)
    allow(curl).to receive(:download).with(ENV["styles_url"]).and_return true

    allow(curl)
      .to receive(:download)
      .with(
        "http://assets-production.applicaster.com/some-assets-zip-path.zip",
        %r{\/tmp\/assets_\d+.zip},
      )

    stub_request(:get, %r{http://assets-production.applicaster.com/.*})
      .to_return(status: 200, body: "", headers: {})
  end

  after(:all) do
    cleanup
  end

  it "has the correct name" do
    expect(subject.name).to eq("generate_plugins")
  end

  context "when plugin configurations file exists" do
    before do
      mock_plugins_json_file
      mock_styles_json_file
    end

    it "adds plugin class name" do
      subject.execute
      expect(File.read(modularapp_properties_file).include?("test-plugin-class1")).to eq true
      expect(File.read(modularapp_properties_file).include?("test-plugin-class2")).to eq true
    end

    it "adds plugin proguard rules" do
      subject.execute
      expect(File.read(proguard_file).include?("-keep class com.test1 {*;}")).to eq true
      expect(File.read(proguard_file).include?("-keep class com.test2 {*;}")).to eq true
    end

    it "adds additional strings resources" do
      subject.execute
      expect(File.read(strings_file).include?("test_client_token")).to eq true
    end

    it "adds plugin maven repositories" do
      subject.execute

      expect(File.read(File.join(Dir.pwd, "build.gradle"))
        .include?("maven { url 'maven-test-repo-url2' }")).to eq true
    end

    it "adds plugin maven repos with credentials" do
      subject.execute

      expect(File.read(File.join(Dir.pwd, "build.gradle")).gsub(/\s+/, "")
        .include?(mock_maven_repo_with_credentials.gsub(/\s+/, ""))).to eq true
    end

    it "adds plugin dependencies" do
      subject.execute

      expect(File.read(File.join(Dir.pwd, "app/build.gradle"))
        .include?("implementation (\"com.applicaster:Test1:0.1.0\") {")).to eq true

      expect(File.read(File.join(Dir.pwd, "app/build.gradle"))
        .include?("implementation (\"com.applicaster:Test2:0.1.0\") {")).to eq true

      expect(File.read(File.join(Dir.pwd, "app/build.gradle"))
        .include?("zapp-pipes-provider")).to eq false

      expect(File.read(File.join(Dir.pwd, "app/build.gradle"))
        .include?("screen-plugin")).to eq false

      expect(File.read(File.join(Dir.pwd, "app/build.gradle"))
        .include?("project-for-@applicaster-name")).to eq true
    end

    context "when android_assets_bundle exists" do
      it "downloads assets zip" do
        expect(curl)
          .to receive(:download)
          .with(
            "http://assets-production.applicaster.com/some-assets-zip-path.zip",
            %r{\/tmp\/assets_\d+.zip},
          )

        subject.execute
      end

      it "unzip the download zip file to the temp dir" do
        expect(Zip::File).to receive(:open)
          .with(%r{\/tmp\/assets_\d+.zip})

        subject.execute
      end
    end

    context "when it has React Native plugins" do
      it "copies styles.json to assets folder" do
        subject.execute
        expect(File.file?("#{AppBuildHelper.assets_dir}/styles.json")).to eq true
      end

      context "and plugin has extra dependencies" do
        it "adds the dependencies" do
          subject.execute

          gradle_file = File.read(File.join(Dir.pwd, "app/build.gradle"))

          expect(gradle_file.include?("implementation (\"com.applicaster:React1:1.0\") {"))
            .to eq true

          expect(gradle_file.include?("implementation (\"com.applicaster:React2:1.0\") {"))
            .to eq true

          expect(gradle_file.include?("npm-package")).to eq false
          expect(gradle_file.include?("@applicaster/something")).to eq false
          expect(gradle_file.include?("zapp-pipes-provider")).to eq false
          expect(gradle_file.include?("screen-plugin")).to eq false
        end
      end

      context "and plugin has project dependencies" do
        context "and it is a production environment" do
          before do
            ENV["build_env"] = "production"
          end

          context "and it is a quickbrick app" do
            before do
              ENV["quick_brick_enabled"] = "true"
            end

            it "adds dependencies" do
              subject.execute

              expect(File.open(WorkspaceHelper.gradle_settings_file.to_s).read)
                .to eq(File.open(qb_gradle_settings).read)
            end
          end

          def gradle_settings
            File.join(Dir.pwd, "spec/fixtures/files/external_projects_settings.gradle")
          end

          def qb_gradle_settings
            File.join(Dir.pwd, "spec/fixtures/files/qb_external_projects_settings.gradle")
          end
        end
      end

      context "and plugin has npm dependencies" do
        it "installs all dependencies" do
          expect_any_instance_of(Kernel).to receive(:system).with("npm install -S npm-dep1@1.0")
          expect_any_instance_of(Kernel).to receive(:system).with("npm install -S npm-dep2@1.0")
          expect_any_instance_of(Kernel).to receive(:system)
            .with("npm install -S @applicaster/npm-dep3@1.0")

          subject.execute
        end
      end
    end
  end

  def mock_plugins_json_file
    FileUtils.cp(
      File.join(Dir.pwd, "spec/fixtures/files/plugin_configurations.json"),
      AppBuildHelper.project_dir,
    )
  end

  def mock_styles_json_file
    FileUtils.cp(File.join(Dir.pwd, "spec/fixtures/files/styles.json"), AppBuildHelper.project_dir)
  end

  def modularapp_properties_file
    File.join(Dir.pwd, "/app/src/main/assets/modularapp.properties")
  end

  def proguard_file
    File.join(Dir.pwd, "app/proguard-rules.pro")
  end

  def strings_file
    File.join(Dir.pwd, "app/src/main/res/values/strings.xml")
  end

  def top_level_build_gradle
    File.join(Dir.pwd, "build.gradle")
  end

  def mock_maven_repo_with_credentials
    %(maven {
           url "test-url"
           credentials {
             username 'user'
             password 'pass'
           }
         }
         )
  end

  def cleanup
    FileUtils.rm(File.join(Dir.pwd, "app/build.gradle"))
    FileUtils.rm(File.join(Dir.pwd, "plugin_configurations.json"))
    FileUtils.rm(proguard_file)
    FileUtils.rm(strings_file)
    FileUtils.rm(modularapp_properties_file)
    FileUtils.rm(File.join(Dir.pwd, "app/src/main/assets/styles.json"))
    FileUtils.cp(File.join(Dir.pwd, "public/files/build.gradle"), top_level_build_gradle)
  end
end
