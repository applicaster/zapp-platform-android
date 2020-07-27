# frozen_string_literal: true

require "spec_helper"

RSpec.describe "quickbrick:create", type: :rake do
  context "with version from ENV['VERSION']" do
    before do
      ENV["VERSION"] = "ABCD-1234"
    end

    after do
      RSpec::Mocks.space.proxy_for(SystemHelper).reset
    end

    it "calls quick-brick:prepare and quick-brick:build with matching version" do
      expect(SystemHelper).to receive(:run)
        .with(/yarn quick-brick:(?:prepare ABCD-1234|build).*/).twice

      Rake::Task["quickbrick:create"].invoke
    end
  end

  context "with REACT_NATIVE_PACKAGER_ROOT option" do
    before do
      Rake::Task["quickbrick:create"].reenable
      ENV["VERSION"] = "ABCD-1234"
      ENV["REACT_NATIVE_PACKAGER_ROOT"] = "http://localhost:8081"
    end

    after do
      RSpec::Mocks.space.proxy_for(SystemHelper).reset
    end

    it "calls prepare script but not build" do
      expect(SystemHelper).to receive(:run)
        .with("yarn quick-brick:prepare ABCD-1234")

      expect(SystemHelper).not_to receive(:run)
        .with("yarn quick-brick:build")

      expect(SystemHelper).not_to receive(:run)
        .with("yarn quick-brick:build:debug")

      Rake::Task["quickbrick:create"].invoke
    end
  end

  context "with skip bundle minification flag" do
    before do
      Rake::Task["quickbrick:create"].reenable
      ENV["VERSION"] = "ABCD-1234"
      ENV["SKIP_BUNDLE_MINIFICATION"] = "true"
    end

    after do
      RSpec::Mocks.space.proxy_for(SystemHelper).reset
    end

    it "calls quick-brick:prepare and quick-brick:build:debug with matching version" do
      expect(SystemHelper).to receive(:run)
        .with(/yarn quick-brick:(?:prepare ABCD-1234|build:debug).*/).twice

      Rake::Task["quickbrick:create"].invoke
    end
  end
end
