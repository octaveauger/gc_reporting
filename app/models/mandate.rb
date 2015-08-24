class Mandate < ActiveRecord::Base
  belongs_to :customer_bank_account, primary_key: 'gc_id', foreign_key: 'customer_bank_account_id'
  has_many :payments, primary_key: 'gc_id', foreign_key: 'mandate_id'

  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
