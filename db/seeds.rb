# db/seeds.rb
require "open-uri"

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
ShippingMethod.create!([
  { name: 'Standard Shipping', code: 'std_ship', carrier: 'J&T', base_price: 15000, active: true },
  { name: 'Express Shipping', code: 'exp_ship', carrier: 'JNE', base_price: 35000, active: true }
])

puts "Creating Payment Methods..."
PaymentMethod.create!([
  { name: 'Bank Transfer', code: 'bank_transfer', provider: 'Manual', active: true, position: 1 },
  { name: 'Credit Card (Stripe)', code: 'stripe_cc', provider: 'Stripe', active: true, position: 2 }
])

puts "Creating Categories..."
footwear = Category.create!(name: 'Footwear', slug: 'footwear')
apparel = Category.create!(name: 'Apparel', slug: 'apparel')
equipment = Category.create!(name: 'Equipment', slug: 'equipment')

hiking_boots = Category.create!(name: 'Hiking Boots', slug: 'hiking-boots', parent: footwear)
jackets = Category.create!(name: 'Jackets', slug: 'jackets', parent: apparel)
backpacks = Category.create!(name: 'Backpacks', slug: 'backpacks', parent: equipment)

def attach_image(product, image_url)
  return if image_url.blank?
  
  begin
    file = URI.open(image_url)
    product_image = product.product_images.create!(primary: true, alt_text: product.name)
    product_image.image.attach(io: file, filename: "#{product.name.parameterize}.jpg", content_type: "image/jpeg")
    puts "Attached image for: #{product.name}"
  rescue => e
    puts "Could not attach image for #{product.name}: #{e.message}"
  end
end

puts "Creating Products..."

# 1. Renegade GTX (Lowa Style)
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

puts "Creating Options for Apparel..."
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

puts "Creating Sample User & Orders..."
user = User.create!(
  email_address: 'customer@example.com',
  password: 'password'
)

# Create a sample completed order
order = Order.create!(
  user: user,
  customer_email: user.email_address,
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
  unit_price: 3850000,
  total_price: 3850000
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

puts "Seeds created successfully! 🚀"
puts "Demo Account: customer@example.com / password"
