# frozen_string_literal: true

module AwsHelper
  def self.aws_credentials_exist?
    ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"] && ENV["AWS_REGION"]
  end
end
