class Mandate < ActiveRecord::Base
  belongs_to :customer_bank_account
  has_many :payments
end
