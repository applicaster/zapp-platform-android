# frozen_string_literal: true

require "spec_helper"

RSpec.describe "quickbrick:create", type: :rake do
  before do
    ENV["VERSION"] = "ABCD-1234"
  end

  context "with version from ENV['VERSION']" do
    it "calls quick-brick:prepare and quick-brick:build with matching version" do
      expect(SystemHelper).to receive(:run)
        .with(/yarn quick-brick:(?:prepare ABCD-1234|build).*/).twice

      Rake::Task["quickbrick:create"].invoke
    end
  end
end
