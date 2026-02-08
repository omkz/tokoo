class StoreSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key)
    find_by(key: key)&.typed_value
  end

  def typed_value
    case value_type
    when 'integer' then value.to_i
    when 'boolean' then value == 'true'
    when 'json' then JSON.parse(value)
    else value
    end
  end
end
