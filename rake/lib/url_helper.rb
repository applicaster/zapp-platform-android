# frozen_string_literal: true

class UrlHelper
  def self.rn_single_bundle_remote_path(bundle_uuid)
    "zapp/" \
    "accounts/#{ENV['accounts_account_id']}/" \
    "apps/#{ENV['bundle_identifier']}/" \
    "#{ENV['store']}/" \
    "#{ENV['version_name']}/" \
    "single_bundle/#{bundle_uuid}/" \
    "android.bundle.js"
  end
end
