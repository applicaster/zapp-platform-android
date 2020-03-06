# frozen_string_literal: true

module SystemHelper
  module_function

  def run(command)
    system(command)
    exit_code = $?.exitstatus || 0 # rubocop:disable Style/SpecialGlobalVars
    return true unless exit_code.positive?

    puts "command failed with code #{exit_code}: ".red + command.yellow
    exit exit_code
  end
end
