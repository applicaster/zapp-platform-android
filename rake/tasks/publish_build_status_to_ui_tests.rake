# frozen_string_literal: true

desc "Upload build results to S3 for ui tests job"
namespace :ui_tests do
  task(
    :publish_build_status, :build_status, :zapp_android_apk_path, :zapp_android_dev_apk_path
  ) do |_task, args|
    git_hub_commit_id = ENV["CIRCLE_SHA1"]
    puts "Github commit id: #{git_hub_commit_id}"
    puts "Zapp android apk path: #{args[:zapp_android_apk_path]}"
    puts "Zapp android dev apk path: #{args[:zapp_android_dev_apk_path]}"
    bucket_name = "assets-production.applicaster.com"

    s3 = Aws::S3::Resource.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )

    # If Zapp Android .apk exist upload it to s3
    if File.exist?(args[:zapp_android_apk_path])
      zapp_android_path_in_bucket = "zapp/qa/#{git_hub_commit_id}/payload.apk"
      obj = s3.bucket(bucket_name).object(zapp_android_path_in_bucket)
      puts "Start uploading Zapp Android apk to s3 for ui tests:"\
      " http://#{bucket_name}/#{zapp_android_path_in_bucket}"
      obj.upload_file(args[:zapp_android_apk_path], acl: "public-read-write")
      puts "Finished uploading Zapp Android apk to S3."
    end

    # If Zapp Android Dev Project .apk exist upload it to s3
    if File.exist?(args[:zapp_android_dev_apk_path])
      zapp_android_dev_path_in_bucket = "zapp/qa/#{git_hub_commit_id}/payload_dev.apk"
      obj = s3.bucket(bucket_name).object(zapp_android_dev_path_in_bucket)
      puts "Start uploading Zapp Android Dev Project apk to s3 for ui tests:"\
      " http://#{bucket_name}/#{zapp_android_dev_path_in_bucket}"
      obj.upload_file(args[:zapp_android_dev_apk_path], acl: "public-read-write")
      puts "Finished uploading Zapp Android Dev Project apk to S3."
    end

    # Upload json status to s3
    status_json_file_name = "build_status.json"
    File.open(status_json_file_name, "w") do |f|
      response_json_obj = {
        "success" => args[:build_status],
      }
      # Only if Zapp Android apk exits append its url to json response
      if File.exist?(args[:zapp_android_apk_path])
        secure_bucket_name = bucket_name.dup
        secure_bucket_name["production"] = "secure"
        response_json_obj["zapp_android_apk"] = "http://" + secure_bucket_name + "/"\
        "#{zapp_android_path_in_bucket}"
      end

      # Only if Zapp Android Dev apk exits append its url to json response
      if File.exist?(args[:zapp_android_dev_apk_path])
        secure_bucket_name = bucket_name.dup
        secure_bucket_name["production"] = "secure"
        response_json_obj["zapp_android_dev_apk"] = "http://" + secure_bucket_name + "/"\
        "#{zapp_android_dev_path_in_bucket}"
      end

      f.puts response_json_obj.to_json
    end

    path_in_bucket = "zapp/qa/#{git_hub_commit_id}/#{status_json_file_name}"
    obj = s3.bucket(bucket_name).object(path_in_bucket)
    puts "Start uploading uploading status json to s3 for ui tests:"\
    " http://#{bucket_name}/#{path_in_bucket}"
    obj.upload_file(status_json_file_name, acl: "public-read-write")
    puts "Finished uploading status json to s3 for ui tests"
  end
end
