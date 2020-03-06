# frozen_string_literal: true

require "spec_helper"

RSpec.describe "prepare_workspace", type: :rake do
  let(:build_app) { Rake::Task["build_app"] }
  let(:generate_dotenv) { Rake::Task["generate_dotenv"] }

  it "has the correct name" do
    expect(subject.name).to eq("prepare_workspace")
  end

  it "runs tasks in the correct order" do
    expect(generate_dotenv).to receive(:invoke).ordered
    expect(build_app).to receive(:invoke).ordered
    subject.execute
  end

  def cleanup
    FileUtils.rm_f("app/google-services.json")
  end
end
