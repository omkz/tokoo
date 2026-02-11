class LoginActivity < ApplicationRecord
  belongs_to :user, optional: true
  
  validates :identity, presence: true
  validates :ip_address, presence: true
end
