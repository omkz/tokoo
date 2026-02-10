module ApplicationHelper
  def set_meta_tags(options = {})
    @meta_tags ||= {}
    @meta_tags.merge!(options)
  end

  def display_meta_tags
    tags = @meta_tags || {}
    
    # Defaults from StoreSetting
    title = tags[:title] || StoreSetting.store_name
    description = tags[:description] || StoreSetting.meta_description
    image = tags[:image] || asset_url("logo.png") # Fallback to logo
    url = tags[:url] || request.original_url
    type = tags[:type] || "website"

    [
      tag.title(title),
      tag.meta(name: "description", content: description),
      # Open Graph
      tag.meta(property: "og:site_name", content: StoreSetting.store_name),
      tag.meta(property: "og:title", content: title),
      tag.meta(property: "og:description", content: description),
      tag.meta(property: "og:image", content: image),
      tag.meta(property: "og:url", content: url),
      tag.meta(property: "og:type", content: type),
      # Twitter
      tag.meta(name: "twitter:card", content: "summary_large_image"),
      tag.meta(name: "twitter:title", content: title),
      tag.meta(name: "twitter:description", content: description),
      tag.meta(name: "twitter:image", content: image)
    ].join("\n").html_safe
  end
end
