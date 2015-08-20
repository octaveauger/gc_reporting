class Customer < ActiveRecord::Base
  belongs_to :organisation
  has_many :customer_bank_accounts, primary_key: 'gc_id', foreign_key: 'customer_id'
end
