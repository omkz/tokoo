# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_10_000335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "address_type", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.boolean "is_default", default: false
    t.string "phone"
    t.string "postal_code"
    t.string "state_province"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "is_default"], name: "index_addresses_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.bigint "product_variant_id"
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["expires_at"], name: "index_carts_on_expires_at"
    t.index ["session_id"], name: "index_carts_on_session_id", unique: true
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "coupons", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "discount_type", null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.datetime "expires_at"
    t.decimal "maximum_discount", precision: 10, scale: 2
    t.decimal "minimum_purchase", precision: 10, scale: 2
    t.integer "per_user_limit"
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0
    t.integer "usage_limit"
    t.index ["active"], name: "index_coupons_on_active"
    t.index ["code"], name: "index_coupons_on_code", unique: true
  end

  create_table "currencies", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.decimal "exchange_rate", precision: 12, scale: 6, default: "1.0"
    t.string "name", null: false
    t.string "symbol", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_currencies_on_code", unique: true
  end

  create_table "inventory_movements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "movement_type", null: false
    t.text "note"
    t.bigint "order_item_id"
    t.bigint "product_id", null: false
    t.bigint "product_variant_id"
    t.integer "quantity", null: false
    t.integer "quantity_after", null: false
    t.integer "quantity_before"
    t.string "reference_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_inventory_movements_on_created_at"
    t.index ["movement_type"], name: "index_inventory_movements_on_movement_type"
    t.index ["order_item_id"], name: "index_inventory_movements_on_order_item_id"
    t.index ["product_id"], name: "index_inventory_movements_on_product_id"
    t.index ["product_variant_id"], name: "index_inventory_movements_on_product_variant_id"
    t.index ["reference_number"], name: "index_inventory_movements_on_reference_number"
    t.index ["user_id"], name: "index_inventory_movements_on_user_id"
  end

  create_table "order_addresses", force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "address_type", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "full_name", null: false
    t.bigint "order_id", null: false
    t.string "phone"
    t.string "postal_code"
    t.string "state_province"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_addresses_on_order_id"
  end

  create_table "order_coupons", force: :cascade do |t|
    t.bigint "coupon_id", null: false
    t.datetime "created_at", null: false
    t.decimal "discount_amount", precision: 10, scale: 2, null: false
    t.bigint "order_id", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id"], name: "index_order_coupons_on_coupon_id"
    t.index ["order_id", "coupon_id"], name: "index_order_coupons_on_order_id_and_coupon_id", unique: true
    t.index ["order_id"], name: "index_order_coupons_on_order_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.string "product_name", null: false
    t.bigint "product_variant_id"
    t.integer "quantity", default: 1, null: false
    t.string "sku", null: false
    t.jsonb "snapshot"
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.string "variant_name"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
    t.index ["sku"], name: "index_order_items_on_sku"
  end

  create_table "order_payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "card_brand"
    t.string "card_last4"
    t.datetime "created_at", null: false
    t.string "currency", default: "IDR"
    t.text "failure_reason"
    t.jsonb "metadata"
    t.bigint "order_id", null: false
    t.datetime "paid_at"
    t.bigint "payment_method_id", null: false
    t.string "payment_type"
    t.datetime "refunded_at"
    t.string "status", default: "pending"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_payments_on_order_id"
    t.index ["payment_method_id"], name: "index_order_payments_on_payment_method_id"
    t.index ["status"], name: "index_order_payments_on_status"
    t.index ["transaction_id"], name: "index_order_payments_on_transaction_id"
  end

  create_table "order_shipments", force: :cascade do |t|
    t.string "carrier"
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.datetime "estimated_delivery_at"
    t.bigint "order_id", null: false
    t.datetime "shipped_at"
    t.decimal "shipping_cost", precision: 10, scale: 2, null: false
    t.bigint "shipping_method_id", null: false
    t.string "status", default: "pending"
    t.jsonb "tracking_events"
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_shipments_on_order_id"
    t.index ["shipping_method_id"], name: "index_order_shipments_on_shipping_method_id"
    t.index ["status"], name: "index_order_shipments_on_status"
    t.index ["tracking_number"], name: "index_order_shipments_on_tracking_number"
  end

  create_table "order_status_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "from_status"
    t.text "note"
    t.boolean "notify_customer", default: false
    t.bigint "order_id", null: false
    t.string "to_status", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_order_status_histories_on_created_at"
    t.index ["order_id"], name: "index_order_status_histories_on_order_id"
    t.index ["user_id"], name: "index_order_status_histories_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "cancellation_reason"
    t.datetime "cancelled_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "customer_email"
    t.string "customer_name"
    t.text "customer_note"
    t.string "customer_phone"
    t.datetime "delivered_at"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.string "fulfillment_status", default: "pending"
    t.text "internal_note"
    t.string "order_number", null: false
    t.string "payment_status", default: "pending"
    t.datetime "shipped_at"
    t.decimal "shipping_cost", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "pending"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["confirmed_at"], name: "index_orders_on_confirmed_at"
    t.index ["fulfillment_status"], name: "index_orders_on_fulfillment_status"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "available_countries"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "fixed_fee", precision: 10, scale: 2, default: "0.0"
    t.string "icon_url"
    t.string "name", null: false
    t.decimal "percentage_fee", precision: 5, scale: 2, default: "0.0"
    t.integer "position", default: 0
    t.string "provider"
    t.jsonb "settings"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_payment_methods_on_active"
    t.index ["code"], name: "index_payment_methods_on_code", unique: true
  end

  create_table "product_analytics", force: :cascade do |t|
    t.integer "add_to_cart_count", default: 0
    t.integer "clicks_count", default: 0
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "product_id", null: false
    t.integer "purchases_count", default: 0
    t.decimal "revenue", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.index ["date"], name: "index_product_analytics_on_date"
    t.index ["product_id", "date"], name: "index_product_analytics_on_product_id_and_date", unique: true
    t.index ["product_id"], name: "index_product_analytics_on_product_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.boolean "primary", default: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "product_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.jsonb "metadata"
    t.bigint "product_id", null: false
    t.string "referrer"
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id"
    t.index ["created_at"], name: "index_product_events_on_created_at"
    t.index ["event_type"], name: "index_product_events_on_event_type"
    t.index ["product_id", "event_type", "created_at"], name: "index_product_events_on_product_and_type_and_time"
    t.index ["product_id"], name: "index_product_events_on_product_id"
    t.index ["user_id"], name: "index_product_events_on_user_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.integer "position", default: 0
    t.boolean "primary", default: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "position"], name: "index_product_images_on_product_id_and_position"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_option_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0
    t.bigint "product_option_id", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["product_option_id", "value"], name: "index_product_option_values_on_product_option_id_and_value", unique: true
    t.index ["product_option_id"], name: "index_product_option_values_on_product_option_id"
  end

  create_table "product_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "name"], name: "index_product_options_on_product_id_and_name", unique: true
    t.index ["product_id"], name: "index_product_options_on_product_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.string "image_url"
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.bigint "product_id", null: false
    t.string "sku", null: false
    t.integer "stock_quantity", default: 0
    t.boolean "track_inventory"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_product_variants_on_active"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "barcode"
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.decimal "cost_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false
    t.jsonb "metadata"
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.text "short_description"
    t.string "sku", null: false
    t.string "slug", null: false
    t.integer "stock_quantity", default: 0
    t.boolean "track_inventory", default: true
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 8, scale: 2
    t.string "weight_unit", default: "kg"
    t.index ["active"], name: "index_products_on_active"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.boolean "approved", default: false
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "helpful_count", default: 0
    t.bigint "order_item_id"
    t.bigint "product_id", null: false
    t.integer "rating", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified_purchase", default: false
    t.index ["approved"], name: "index_reviews_on_approved"
    t.index ["order_item_id"], name: "index_reviews_on_order_item_id"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "available_countries"
    t.decimal "base_price", precision: 10, scale: 2, default: "0.0"
    t.string "carrier"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "free_shipping_threshold", precision: 10, scale: 2
    t.integer "max_delivery_days"
    t.integer "min_delivery_days"
    t.string "name", null: false
    t.decimal "price_per_kg", precision: 10, scale: 2
    t.string "pricing_type", default: "flat_rate"
    t.jsonb "settings"
    t.string "tracking_url"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_shipping_methods_on_active"
    t.index ["code"], name: "index_shipping_methods_on_code", unique: true
  end

  create_table "store_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.string "value_type", default: "string"
    t.index ["key"], name: "index_store_settings_on_key", unique: true
  end

  create_table "tax_rates", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "priority", default: 0
    t.decimal "rate", precision: 5, scale: 2, null: false
    t.string "state_province"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tax_rates_on_active"
    t.index ["country_code", "state_province"], name: "index_tax_rates_on_country_code_and_state_province"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "variant_option_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_option_value_id", null: false
    t.bigint "product_variant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_option_value_id"], name: "index_variant_option_values_on_product_option_value_id"
    t.index ["product_variant_id", "product_option_value_id"], name: "index_variant_option_values_uniqueness", unique: true
    t.index ["product_variant_id"], name: "index_variant_option_values_on_product_variant_id"
  end

  create_table "webauthn_credentials", force: :cascade do |t|
    t.integer "authentication_factor", limit: 2, null: false
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "nickname"
    t.string "public_key"
    t.bigint "sign_count"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["external_id"], name: "index_webauthn_credentials_on_external_id", unique: true
    t.index ["user_id"], name: "index_webauthn_credentials_on_user_id"
  end

  create_table "wishlists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_wishlists_on_product_id"
    t.index ["user_id", "product_id"], name: "index_wishlists_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "inventory_movements", "order_items"
  add_foreign_key "inventory_movements", "product_variants"
  add_foreign_key "inventory_movements", "products"
  add_foreign_key "inventory_movements", "users"
  add_foreign_key "order_addresses", "orders"
  add_foreign_key "order_coupons", "coupons"
  add_foreign_key "order_coupons", "orders"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_payments", "orders"
  add_foreign_key "order_payments", "payment_methods"
  add_foreign_key "order_shipments", "orders"
  add_foreign_key "order_shipments", "shipping_methods"
  add_foreign_key "order_status_histories", "orders"
  add_foreign_key "order_status_histories", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "product_analytics", "products"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "product_events", "products"
  add_foreign_key "product_events", "users"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_option_values", "product_options"
  add_foreign_key "product_options", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "reviews", "order_items"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "variant_option_values", "product_option_values"
  add_foreign_key "variant_option_values", "product_variants"
  add_foreign_key "webauthn_credentials", "users"
  add_foreign_key "wishlists", "products"
  add_foreign_key "wishlists", "users"
end
