class StoreSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key, default = nil)
    find_by(key: key)&.typed_value || default
  end

  def self.set(key, value, type = 'string')
    setting = find_or_initialize_by(key: key)
    setting.value_type = type
    setting.value = value.to_s
    setting.save!
  end

  # Convenience Methods
  def self.store_name
    get('store_name', 'Tokoo')
  end

  def self.store_email
    get('store_email')
  end

  def self.store_whatsapp
    get('store_whatsapp')
  end

  def self.store_address
    get('store_address')
  end

  def self.meta_description
    get('meta_description', 'Modern E-commerce built with Tokoo')
  end

  def typed_value
    case value_type
    when 'integer' then value.to_i
    when 'boolean' then value == 'true'
    when 'json' then value.present? ? JSON.parse(value) : {}
    else value
    end
  end
end
