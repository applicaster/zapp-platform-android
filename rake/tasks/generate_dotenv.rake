# frozen_string_literal: true

require "app_build_helper"
require "dotenv"
require "dotenv/tasks"
require "curb"
require "colorize"
require "java-properties"
require "pry"

desc "fetch version build params and generate .env file"
task generate_dotenv: :dotenv do
  if ENV["ZAPP_TOKEN"].present? && ENV["VERSION"].present?
    puts "fetching version build_params".green

    curl = Curl::Easy.new(
      "https://zapp.applicaster.com/api/v1/admin/build_params?app_version_id="\
      "#{ENV['VERSION']}&access_token=#{ENV['ZAPP_TOKEN']}",
    )

    curl.perform
    build_params = curl.body_str
    puts "writing .env file".green

    JavaProperties.write(
      JSON.parse(build_params)["build_params"],
      File.join(AppBuildHelper.project_dir, ".env"),
    )

    Dotenv.overload(".env")
  else
    puts "skipping .env creation".yellow
  end
end
