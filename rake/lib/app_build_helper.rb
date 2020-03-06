# frozen_string_literal: true

class AppBuildHelper
  def self.project_dir
    File.join(__dir__, "../..")
  end

  def self.app_dir
    File.join(project_dir, "app")
  end

  def self.rake_dir
    File.join(project_dir, "rake")
  end

  def self.modular_sdk_path
    File.join(project_dir, "android_generic_app")
  end

  def self.resources_dir
    File.join(project_dir, "app/src/main/res")
  end

  def self.assets_dir
    File.join(project_dir, "app/src/main/assets")
  end

  def self.templates_dir
    File.join(project_dir, "templates")
  end

  def self.template_dir(template, rtl = "false")
    File.join(templates_dir, template, rtl == "true" ? "rtl" : "ltr")
  end

  def self.smartphone_values_folder
    File.join(resources_dir, "values")
  end

  def self.tablet_values_folder
    File.join(resources_dir, "values-sw600dp")
  end

  def self.global_fonts_dir
    File.join(project_dir, "fonts")
  end

  def self.fonts_dir
    File.join(assets_dir, "fonts")
  end

  def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word
        .to_s
        .gsub(%r{/\/(.?)/}) { "::" + Regexp.last_match(1).upcase }
        .gsub(/(^|_)(.)/) { Regexp.last_match(2).upcase }
    else
      lower_case_and_underscored_word.first +
        camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

  def self.squash_styles_json(styles_json, tv_flavor = false)
    styles_json.each_with_object({}) do |(device_target, values), result|
      next if skip_styles_json?(device_target, tv_flavor)

      result[device_target] = result[device_target] || {}
      result[device_target].merge!(values.delete_if { |_k, v| v.nil? })
    end
  end

  def self.skip_styles_json?(device_target, tv_flavor)
    (tv_flavor && device_target != "android_tv") || (!tv_flavor && device_target == "android_tv")
  end

  def self.expand_assets(assets_url, allow_overwrite = true)
    return unless assets_url.present?

    timestamped_zip_name = "assets_#{Time.now.to_i}.zip"
    download_zip(assets_url, timestamped_zip_name)
    unzip("/tmp/#{timestamped_zip_name}", resources_dir, allow_overwrite)
  end

  def self.unzip(src_path, dst_path, allow_overwrite = true)
    puts "Unzipping...".green
    Zip.on_exists_proc = allow_overwrite
    Dir.mktmpdir do |temp_dir|
      Zip::File.open(src_path) do |zip_file|
        zip_file.each do |entry|
          puts "Extracting #{entry.name}"
          entry.extract("#{temp_dir}/#{entry.name}") { true }
        end

        copy_extracted_resources(temp_dir, dst_path)
      end
    end
  end

  def self.download_zip(assets_url, timestamped_zip_name)
    puts "Downloading assets library from #{assets_url}...".yellow
    Curl::Easy.download(assets_url, "/tmp/#{timestamped_zip_name}")
  end

  def self.copy_extracted_resources(temp_dir, dst_path)
    nested_dir_array = Dir.glob("#{temp_dir}/**/**/drawable-*/*.*").map do |dir|
      dir.gsub(%r{[\w]*drawable-[\w]+\/[\w]+\.[\w]+\z}, "").to_s
    end.uniq

    nested_dir_array.each do |entry|
      FileUtils.cp_r(Dir.glob("#{entry}/*"), dst_path.to_s)
    end
  end
end
