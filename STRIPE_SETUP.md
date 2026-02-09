# Stripe Payment Setup Guide

## 1. Get Stripe API Keys

1. Sign up at [Stripe](https://stripe.com)
2. Go to [Dashboard > Developers > API keys](https://dashboard.stripe.com/test/apikeys)
3. Copy your **Publishable key** (starts with `pk_test_` for test mode)
4. Copy your **Secret key** (starts with `sk_test_` for test mode)

## 2. Setup Webhook

1. Go to [Dashboard > Developers > Webhooks](https://dashboard.stripe.com/test/webhooks)
2. Click "Add endpoint"
3. Set endpoint URL to: `https://yourdomain.com/stripe/webhook`
4. Select events to listen to:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `payment_intent.canceled`
5. Copy the **Signing secret** (starts with `whsec_`)

## 3. Configure Credentials

### Option A: Rails Credentials (Recommended)

```bash
EDITOR="code --wait" rails credentials:edit
```

Add:
```yaml
stripe:
  publishable_key: pk_test_your_key_here
  secret_key: sk_test_your_key_here
  webhook_secret: whsec_your_secret_here
```

### Option B: Environment Variables

Add to your `.env` file or deployment environment:

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_secret_here
```

## 4. Test Payment

Use Stripe test cards:
- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- **3D Secure**: `4000 0025 0000 3155`

Use any future expiry date, any CVC, and any postal code.

## 5. Payment Flow

1. Customer completes checkout
2. Redirected to payment page
3. Selects payment method (Stripe Credit Card)
4. Enters card details
5. Payment processed via Stripe
6. Webhook updates order status automatically

## 6. Adding Midtrans (Future)

The payment system is designed to be extensible. To add Midtrans:

1. Create `app/services/midtrans_processor.rb` extending `PaymentProcessor`
2. Add case in `PaymentsController#create`
3. Create `MidtransWebhooksController` similar to `StripeWebhooksController`

## Troubleshooting

- **Webhook not working?** Make sure your endpoint is publicly accessible (use ngrok for local testing)
- **Payment fails?** Check Stripe Dashboard > Logs for error details
- **Metadata not saving?** Ensure `metadata` column in `order_payments` is JSONB type

