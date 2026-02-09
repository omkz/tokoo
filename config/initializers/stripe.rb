# Stripe configuration
# Set your Stripe keys in Rails credentials or environment variables
#
# Rails credentials:
#   rails credentials:edit
#   Add:
#     stripe:
#       publishable_key: pk_test_...
#       secret_key: sk_test_...
#       webhook_secret: whsec_...
#
# Or use environment variables:
#   STRIPE_PUBLISHABLE_KEY=pk_test_...
#   STRIPE_SECRET_KEY=sk_test_...
#   STRIPE_WEBHOOK_SECRET=whsec_...

if Rails.env.production?
  Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV['STRIPE_SECRET_KEY']
else
  # Use test keys in development/test
  Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV['STRIPE_SECRET_KEY'] || 'sk_test_placeholder'
end
