# db/seeds.rb

puts "Cleaning database..."
# Delete in reverse order of dependencies
[
  InventoryMovement, ProductEvent, ProductAnalytics, OrderCoupon, Coupon, 
  Review, Wishlist, CartItem, Cart, OrderStatusHistory, OrderShipment, 
  OrderPayment, OrderAddress, OrderItem, Order, Address, VariantOptionValue, 
  ProductVariant, ProductOptionValue, ProductOption, ProductImage, 
  ProductCategory, Product, Category, StoreSetting, TaxRate, ShippingMethod, 
  PaymentMethod, Currency
].each(&:delete_all)

puts "Creating Currencies..."
Currency.create!([
  { code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', exchange_rate: 1.0, active: true },
  { code: 'USD', name: 'US Dollar', symbol: '$', exchange_rate: 15600.0, active: true }
])

puts "Creating Store Settings..."
StoreSetting.create!([
  { key: 'store_name', value: 'Tokoo E-Commerce', value_type: 'string' },
  { key: 'contact_email', value: 'hello@tokoo.com', value_type: 'string' },
  { key: 'maintenance_mode', value: 'false', value_type: 'boolean' }
])

puts "Creating Tax Rates..."
TaxRate.create!(name: 'PPN', country_code: 'ID', rate: 11.0, active: true)

puts "Creating Shipping Methods..."
ShippingMethod.create!([
  { name: 'JNE Reguler', code: 'jne_reg', carrier: 'JNE', base_price: 10000, active: true },
  { name: 'JNE YES', code: 'jne_yes', carrier: 'JNE', base_price: 20000, active: true },
  { name: 'GoSend Instant', code: 'gosend_instant', carrier: 'Gojek', base_price: 15000, active: true }
])

puts "Creating Payment Methods..."
PaymentMethod.create!([
  { name: 'Bank Transfer', code: 'bank_transfer', provider: 'Manual', active: true, position: 1 },
  { name: 'Credit Card (Stripe)', code: 'stripe_cc', provider: 'Stripe', active: true, position: 2 },
  { name: 'GoPay', code: 'gopay', provider: 'Midtrans', active: true, position: 3 }
])

puts "Creating Categories..."
electronics = Category.create!(name: 'Electronics', slug: 'electronics')
fashion = Category.create!(name: 'Fashion', slug: 'fashion')
home = Category.create!(name: 'Home & Living', slug: 'home-living')

laptops = Category.create!(name: 'Laptops', slug: 'laptops', parent: electronics)
mens_wear = Category.create!(name: 'Mens Wear', slug: 'mens-wear', parent: fashion)

puts "Creating Products..."

# 1. Simple Product: MacBook Pro
macbook = Product.create!(
  name: 'MacBook Pro M3 14-inch',
  description: 'The most advanced chips ever built for a personal computer.',
  price: 24999000,
  sku: 'MAC-M3-14',
  stock_quantity: 50,
  featured: true
)
macbook.categories << laptops
ProductImage.create!(product: macbook, url: 'https://placehold.co/600x400?text=MacBook+Pro+M3', primary: true)

# 2. Variable Product: T-Shirt
tshirt = Product.create!(
  name: 'Tokoo Essential T-Shirt',
  description: 'Premium cotton t-shirt for everyday wear.',
  price: 150000,
  sku: 'TSHIRT-ESS',
  stock_quantity: 200
)
tshirt.categories << mens_wear
ProductImage.create!(product: tshirt, url: 'https://placehold.co/600x400?text=Premium+T-Shirt', primary: true)

puts "Creating Options and Variants for T-Shirt..."
size_opt = ProductOption.create!(product: tshirt, name: 'Size', position: 1)
color_opt = ProductOption.create!(product: tshirt, name: 'Color', position: 2)

s_val = ProductOptionValue.create!(product_option: size_opt, value: 'S', position: 1)
m_val = ProductOptionValue.create!(product_option: size_opt, value: 'M', position: 2)
l_val = ProductOptionValue.create!(product_option: size_opt, value: 'L', position: 3)

black_val = ProductOptionValue.create!(product_option: color_opt, value: 'Black', position: 1)
white_val = ProductOptionValue.create!(product_option: color_opt, value: 'White', position: 2)

# Create some variants
[
  { vals: [s_val, black_val], suffix: 'S-BLK' },
  { vals: [m_val, black_val], suffix: 'M-BLK' },
  { vals: [l_val, black_val], suffix: 'L-BLK' },
  { vals: [s_val, white_val], suffix: 'S-WHT' },
  { vals: [m_val, white_val], suffix: 'M-WHT' }
].each do |variant_data|
  variant = ProductVariant.create!(
    product: tshirt,
    sku: "TSHIRT-ESS-#{variant_data[:suffix]}",
    price: 150000,
    stock_quantity: 20,
    active: true
  )
  variant_data[:vals].each do |val|
    VariantOptionValue.create!(product_variant: variant, product_option_value: val)
  end
  variant.save! # Trigger name generation callback
end

puts "Creating Example Coupon..."
Coupon.create!(
  code: 'WELCOME10', 
  discount_type: 'percentage', 
  discount_value: 10.0, 
  minimum_purchase: 100000,
  starts_at: Time.current,
  active: true
)

puts "Seeds created successfully! 🚀"
