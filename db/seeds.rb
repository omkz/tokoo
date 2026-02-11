# db/seeds.rb
require "open-uri"
require "faker"

puts "Cleaning database..."
# Delete in reverse order of dependencies
[
  InventoryMovement, ProductEvent, ProductAnalytics, OrderCoupon, Coupon, 
  Review, Wishlist, CartItem, Cart, OrderStatusHistory, OrderShipment, 
  OrderPayment, OrderAddress, OrderItem, Order, Address, VariantOptionValue, 
  ProductVariant, ProductOptionValue, ProductOption, ProductImage, 
  ProductCategory, Product, Category, StoreSetting, TaxRate, ShippingMethod, 
  PaymentMethod, Currency, Session, WebauthnCredential, User
].each(&:delete_all)

puts "Creating Currencies..."
Currency.create!([
  { code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', exchange_rate: 1.0, active: true },
  { code: 'USD', name: 'US Dollar', symbol: '$', exchange_rate: 15600.0, active: true }
])

puts "Creating Store Settings..."
StoreSetting.create!([
  { key: 'store_name', value: 'Outdoor Adventures', value_type: 'string' },
  { key: 'store_email', value: 'support@outdooradv.id', value_type: 'string' },
  { key: 'meta_description', value: 'Premium outdoor gear for your next adventure. Hiking, Trekking, and Mountaineering experts.', value_type: 'string' },
  { key: 'bank_transfer_details', value: "Bank BCA\nAcc: 1234567890\nName: PT Outdoor Adventures\n\nPlease include your Order Number in the transfer note.", value_type: 'string' }
])

puts "Creating Tax Rates..."
TaxRate.create!(name: 'PPN 11%', country_code: 'ID', rate: 11.0, active: true)

puts "Creating Shipping Methods..."
mnc = ShippingMethod.create!([
  { name: 'Standard Shipping', code: 'std_ship', carrier: 'J&T', base_price: 15000, active: true },
  { name: 'Express Shipping', code: 'exp_ship', carrier: 'JNE', base_price: 35000, active: true }
])

puts "Creating Payment Methods..."
PaymentMethod.create!([
  { name: 'Bank Transfer', code: 'bank_transfer', provider: 'Manual', active: true, position: 1 },
  { name: 'Credit Card (Stripe)', code: 'stripe_cc', provider: 'Stripe', active: true, position: 2 }
])

# Helper for attaching images
def attach_image(product, image_url = nil)
  return if image_url.blank? && Rails.env.test? # Skip in test if no URL provided
  
  image_url ||= "https://source.unsplash.com/random/600x600/?hiking,outdoor,gear"
  
  begin
    file = URI.open(image_url)
    product_image = product.product_images.create!(primary: true, alt_text: product.name)
    filename = "#{product.name.parameterize}-#{SecureRandom.hex(4)}.jpg"
    product_image.image.attach(io: file, filename: filename, content_type: "image/jpeg")
    putc "."
  rescue => e
    puts "\nCould not attach image for #{product.name}: #{e.message}"
  end
end

puts "Creating Categories..."
# Core Categories
footwear = Category.create!(name: 'Footwear', slug: 'footwear')
apparel = Category.create!(name: 'Apparel', slug: 'apparel')
equipment = Category.create!(name: 'Equipment', slug: 'equipment')

main_categories = [footwear, apparel, equipment]

# Subcategories
hiking_boots = Category.create!(name: 'Hiking Boots', slug: 'hiking-boots', parent: footwear)
jackets = Category.create!(name: 'Jackets', slug: 'jackets', parent: apparel)
backpacks = Category.create!(name: 'Backpacks', slug: 'backpacks', parent: equipment)

# Curated Outdoor Subcategories
puts "Creating detailed subcategories..."

# Equipment Subcategories
[
  'Tents', 'Sleeping Bags', 'Trekking Poles', 'Hydration Packs', 
  'Climbing Gear', 'Headlamps', 'Navigation', 'Camp Kitchen'
].each do |name|
  Category.create!(name: name, slug: name.parameterize, parent: equipment)
end

# Apparel Subcategories
[
  'Base Layers', 'T-Shirts', 'Hiking Pants', 'Shorts', 
  'Rainwear', 'Gloves', 'Socks', 'Headwear'
].each do |name|
  Category.create!(name: name, slug: name.parameterize, parent: apparel)
end

# Footwear Subcategories
[
  'Trail Running Shoes', 'Hiking Sandals', 'Mountaineering Boots', 
  'Approach Shoes', 'Gaiters'
].each do |name|
  Category.create!(name: name, slug: name.parameterize, parent: footwear)
end

puts "\nCreating Products (This may take a while to download images)..."

# 1. Renegade GTX (Lowa Style) - Keep Core Products
renegade = Product.create!(
  name: 'Renegade GTX Mid Hiking Boots',
  description: 'The legendary multi-functional boot that is perfect for day hikes and light backpacking. GORE-TEX lining keeps your feet dry.',
  price: 3850000,
  sku: 'BOOT-REN-001',
  stock_quantity: 25,
  featured: true
)
renegade.categories << hiking_boots
attach_image(renegade, "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=600")

# 2. Alpine Expert
alpine = Product.create!(
  name: 'Alpine Expert Mountaineering Boot',
  description: 'Pro-grade insulation and stiff sole for serious climbing and technical terrain. Compatible with automatic crampons.',
  price: 6200000,
  sku: 'BOOT-ALP-001',
  stock_quantity: 10
)
alpine.categories << hiking_boots
attach_image(alpine, "https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&q=80&w=600")

# 3. All-Weather Jacket
jacket = Product.create!(
  name: 'Storm-Shield Hard Shell Jacket',
  description: 'High-performance waterproof and breathable shell for extreme mountain weather. Lightweight and packable.',
  price: 2450000,
  sku: 'APP-JAC-001',
  stock_quantity: 15
)
jacket.categories << jackets
attach_image(jacket, "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=600")

# 4. Expedition Backpack
pack = Product.create!(
  name: 'Summit-75 Expedition Backpack',
  description: 'A 75L powerhouse designed for multi-day expeditions. Features adjustable suspension and hydration compatibility.',
  price: 4150000,
  sku: 'EQP-PAC-75L',
  stock_quantity: 8
)
pack.categories << backpacks
attach_image(pack, "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&q=80&w=600")

# Generate ~50 Random Products
outdoor_images = [
  "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&q=80&w=600", # Shirt
  "https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&q=80&w=600", # Shirt
  "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&q=80&w=600", # Shirt
  "https://images.unsplash.com/photo-1582552938357-32b906df40cb?auto=format&fit=crop&q=80&w=600", # Jeans
  "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&q=80&w=600", # Jeans
  "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&q=80&w=600", # Shirt
  "https://images.unsplash.com/photo-1620799140408-ed5341cd2431?auto=format&fit=crop&q=80&w=600",
  "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?auto=format&fit=crop&q=80&w=600",
  "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&q=80&w=600"
]

46.times do |i|
  category = Category.all.sample
  name = "#{Faker::Commerce.product_name} #{Faker::Science.element}"
  
  product = Product.create!(
    name: name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 100_000..5_000_000).to_f,
    sku: "#{category.slug[0..2].upcase}-#{SecureRandom.hex(3).upcase}",
    stock_quantity: rand(0..100),
    featured: [true, false].sample
  )
  product.categories << category
  
  # Pick a random image from our list to avoid too many API calls/slow downloads or use a specific topic
  image_url = outdoor_images.sample
  attach_image(product, image_url)
end

puts "\nCreating Options for Apparel..."
size_opt = ProductOption.create!(product: jacket, name: 'Size', position: 1)
['S', 'M', 'L', 'XL'].each_with_index do |size, i|
  val = ProductOptionValue.create!(product_option: size_opt, value: size, position: i + 1)
  
  # Create variant
  variant = ProductVariant.create!(
    product: jacket,
    sku: "#{jacket.sku}-#{size}",
    price: jacket.price,
    stock_quantity: 10,
    active: true
  )
  VariantOptionValue.create!(product_variant: variant, product_option_value: val)
  variant.save!
end

puts "Creating Users..."
# Admin User
admin = User.create!(
  email_address: 'admin@outdooradv.id',
  password: 'password',
  admin: true
)

# Demo Customer
demo_user = User.create!(
  email_address: 'customer@example.com',
  password: 'password',
  admin: false
)

# Random Users
20.times do
  User.create!(
    email_address: Faker::Internet.unique.email,
    password: 'password',
    admin: false
  )
end

puts "Creating Orders..."
users = User.all
products = Product.all
shipping_methods = ShippingMethod.all

# Create a sample completed order for Demo User
order = Order.create!(
  user: demo_user,
  customer_email: demo_user.email_address,
  customer_name: 'John Adventurer',
  order_number: "ORD-#{SecureRandom.hex(4).upcase}",
  status: 'delivered',
  payment_status: 'paid',
  fulfillment_status: 'fulfilled',
  subtotal: 3850000,
  shipping_cost: 35000,
  total: 3885000,
  confirmed_at: 2.days.ago,
  delivered_at: 1.day.ago
)

OrderItem.create!(
  order: order,
  product: renegade,
  product_name: renegade.name,
  sku: renegade.sku,
  quantity: 1,
  unit_price: renegade.price,
  total_price: renegade.price
)

OrderAddress.create!(
  order: order,
  address_type: 'shipping',
  full_name: 'John Adventurer',
  address_line1: 'Jl. Pegunungan No. 10',
  city: 'Bandung',
  state_province: 'Jawa Barat',
  postal_code: '40123',
  country: 'ID'
)

# Random Orders
50.times do
  user = users.sample
  # 50% chance of guest order
  is_guest = [true, false].sample
  
  status_options = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled']
  status = status_options.sample
  
  payment_status = case status
                   when 'pending' then 'pending'
                   when 'cancelled' then 'refunded'
                   else 'paid'
                   end
  
  fulfillment_status = case status
                       when 'shipped', 'delivered' then 'fulfilled'
                       else 'unfulfilled'
                       end

  order = Order.create!(
    user: is_guest ? nil : user,
    customer_email: is_guest ? Faker::Internet.email : user.email_address,
    customer_name: Faker::Name.name,
    order_number: "ORD-#{SecureRandom.hex(4).upcase}",
    status: status,
    payment_status: payment_status,
    fulfillment_status: fulfillment_status,
    subtotal: 0, # Will calculate
    shipping_cost: [15000, 35000].sample,
    total: 0, # Will calculate
    confirmed_at: ['confirmed', 'shipped', 'delivered'].include?(status) ? Faker::Time.backward(days: 30) : nil,
    delivered_at: status == 'delivered' ? Faker::Time.backward(days: 10) : nil
  )

  # Add Items
  subtotal = 0
  rand(1..5).times do
    product = products.sample
    quantity = rand(1..3)
    item_total = product.price * quantity
    
    OrderItem.create!(
      order: order,
      product: product,
      product_name: product.name,
      sku: product.sku,
      quantity: quantity,
      unit_price: product.price,
      total_price: item_total
    )
    subtotal += item_total
  end
  
  order.update!(
    subtotal: subtotal,
    total: subtotal + order.shipping_cost
  )

  # Add Address
  OrderAddress.create!(
    order: order,
    address_type: 'shipping',
    full_name: order.customer_name,
    address_line1: Faker::Address.street_address,
    city: Faker::Address.city,
    state_province: Faker::Address.state,
    postal_code: Faker::Address.zip_code,
    country: 'ID'
  )
  
  print "."
end

puts "\nSeeds created successfully! 🚀"
puts "Total Products: #{Product.count}"
puts "Total Users: #{User.count}"
puts "Total Orders: #{Order.count}"
puts "Demo Account: customer@example.com / password"
