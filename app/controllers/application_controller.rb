class ApplicationController < ActionController::Base
  include Authentication
  
  before_action :set_paper_trail_whodunnit
  
  helper_method :current_user, :current_cart, :display_meta_tags, :set_meta_tags
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def set_meta_tags(options = {})
    @meta_tags ||= {}
    @meta_tags.merge!(options)
  end

  def display_meta_tags
    tags = @meta_tags || {}
    
    # Defaults from StoreSetting
    title = tags[:title] || StoreSetting.store_name
    description = tags[:description] || StoreSetting.meta_description
    image = tags[:image]
    url = tags[:url] || request.original_url
    type = tags[:type] || "website"

    res = [
      helpers.tag.title(title),
      helpers.tag.meta(name: "description", content: description),
      # Open Graph
      helpers.tag.meta(property: "og:site_name", content: StoreSetting.store_name),
      helpers.tag.meta(property: "og:title", content: title),
      helpers.tag.meta(property: "og:description", content: description),
      helpers.tag.meta(property: "og:url", content: url),
      helpers.tag.meta(property: "og:type", content: type),
      # Twitter
      helpers.tag.meta(name: "twitter:card", content: "summary_large_image"),
      helpers.tag.meta(name: "twitter:title", content: title),
      helpers.tag.meta(name: "twitter:description", content: description)
    ]

    if image.present?
      res << helpers.tag.meta(property: "og:image", content: image)
      res << helpers.tag.meta(name: "twitter:image", content: image)
    end

    res.join("\n").html_safe
  end

  private

  def current_user
    Current.user
  end

  def current_cart
    @current_cart ||= find_or_create_cart
  end

  def find_or_create_cart
    if session[:cart_id]
      cart = Cart.find_by(id: session[:cart_id])
      if cart
        cart.update(user: current_user) if current_user && cart.user.nil?
        return cart
      end
    end

    cart = Cart.create(user: current_user, session_id: SecureRandom.uuid)
    session[:cart_id] = cart.id
    cart
  end
end
