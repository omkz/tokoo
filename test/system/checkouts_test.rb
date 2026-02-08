require "application_system_test_case"

class CheckoutsTest < ApplicationSystemTestCase
  setup do
    @product = Product.create!(
      name: "Test Laptop",
      description: "A powerful laptop",
      price: 1000.00,
      stock_quantity: 10,
      sku: "TEST-SKU"
    )
    @shipping_method = ShippingMethod.create!(
      name: "Standard Shipping",
      code: "STD",
      base_price: 10.00,
      active: true,
      pricing_type: "flat_rate"
    )
  end

  test "visiting the checkout flow" do
    visit "/"
    
    # Simulate adding to cart (assuming there's a way from product page)
    visit "/products/#{@product.slug}" # Using slug as per route definition
    
    assert_selector "h1", text: "Test Laptop"
    find("button", text: "Add to Cart").click
    
    # Go to checkout
    visit "/checkouts/new"
    
    assert_selector "h1", text: "Checkout"
    
    # Fill in customer info
    fill_in "Email", with: "test@example.com"
    fill_in "Full Name", with: "Test User"
    fill_in "Phone Number", with: "1234567890"
    
    # Fill in shipping address
    fill_in "Recipient Name", with: "Test Recipient"
    fill_in "Address Line 1", with: "123 Test St"
    fill_in "City", with: "Test City"
    fill_in "Postal Code", with: "12345"
    fill_in "Country", with: "Indonesia"
    
    # Select shipping method
    choose "Standard Shipping"
    
    # Submit
    click_on "Place Order"
    
    # Verify redirection and content
    assert_text "Thank you!"
    assert_text "It's on the way!"
    assert_text "Test Laptop"
    
    # Verify Order created
    order = Order.last
    assert_equal "test@example.com", order.customer_email
    assert_equal 1010.00, order.total # 1000 + 10
    assert_equal "pending", order.status
  end
end
