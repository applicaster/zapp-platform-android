# frozen_string_literal: true

class S3Helper
  def self.resource_from_env_vars
    Aws::S3::Resource.new(
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region: ENV["AWS_REGION"],
    )
  end
end
