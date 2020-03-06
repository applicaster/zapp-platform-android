# frozen_string_literal: true

require "mini_magick"
require "fileutils"
require "app_build_helper"
require "dotenv"
require "dotenv/tasks"
require "colorize"
require "pry"

desc "adds debug ribbon layer on top of all ic_launcher.png"
task compose_debug_ribbon: :dotenv do
  if ENV["key_store_url"].blank?
    puts "Adding 'debug' ribbon on launchers".green

    ribbon = MiniMagick::Image.open(
      "#{AppBuildHelper.project_dir}/resources/build-icon-ribbon.svg",
    )

    Dir["#{AppBuildHelper.resources_dir}/**/*"].each do |path|
      next unless path =~ %r{mipmap-.+\/ic_launcher.png}

      ic_launcher = MiniMagick::Image.open(path)
      launcher_size = "#{ic_launcher.width}x#{ic_launcher.height}"

      result = ic_launcher.composite(ribbon) do |c|
        c.compose "Over"
        c.thumbnail launcher_size
        c.background "none"
      end

      result.write path
    end
  end
end
