# frozen_string_literal: true

module CleanupSpecHelper
  RSpec.configure do |config|
    config.include self
  end

  def clean_build_gradle_env_vars
    ENV["min_sdk_version"] = nil
    ENV["gradle_build_tools_classpath"] = nil
    ENV["gradle_wrapper_version"] = nil
  end
end
