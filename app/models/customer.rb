class Customer < ActiveRecord::Base
  belongs_to :organisation
  has_many :customer_bank_accounts
end
