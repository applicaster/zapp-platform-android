# frozen_string_literal: true

module AndroidManifestHelper
  def app_links_intent_filters
    return unless ENV["app_links_hosts"].present?

    builder = Builder::XmlMarkup.new(indent: 4, margin: 3)

    builder.tag!("intent-filter", "android:autoVerify" => "true") do
      add_base_children(builder)

      ENV["app_links_hosts"].split(",").each do |host|
        add_host_only(builder, host) unless ENV["app_links_patterns"].present?

        ENV["app_links_patterns"].split(",").each do |pattern|
          builder.data(intent_filter_data("http", host, pattern))
          builder.data(intent_filter_data("https", host, pattern))
        end
      end
    end
  end

  private

  def intent_filter_data(scheme, host, path_pattern = nil)
    {
      "android:scheme" => scheme,
      "android:host" => host,
      "android:pathPattern" => path_pattern,
    }.reject { |_key, value| value.blank? }
  end

  def add_host_only(xml_builder, host)
    xml_builder.data(intent_filter_data("http", host))
    xml_builder.data(intent_filter_data("https", host))
  end

  def add_base_children(xml_builder)
    xml_builder.action("android:name" => "android.intent.action.VIEW")
    xml_builder.category("android:name" => "android.intent.category.DEFAULT")
    xml_builder.category("android:name" => "android.intent.category.BROWSABLE")
  end
end
