class CustomerBankAccount < ActiveRecord::Base
  belongs_to :customer, primary_key: 'gc_id', foreign_key: 'customer_id'
  has_many :mandates, primary_key: 'gc_id', foreign_key: 'customer_bank_account_id'

  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
