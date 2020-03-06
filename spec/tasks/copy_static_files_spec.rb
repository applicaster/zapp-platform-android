# frozen_string_literal: true

RSpec.describe "copy_static_files", type: :rake do
  before do
    subject.execute
  end

  after(:all) do
    cleanup
  end

  it "has the correct name" do
    expect(subject.name).to eq("copy_static_files")
  end

  it "copy network security config xml " do
    expect(File.open("rake/static_files/network_security_config.xml").read)
      .to be_equivalent_to(File.open("app/src/main/res/xml/network_security_config.xml").read)
  end

  def cleanup; end
end
