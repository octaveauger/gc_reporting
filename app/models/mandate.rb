class Mandate < ActiveRecord::Base
  belongs_to :customer_bank_account, primary_key: 'gc_id', foreign_key: 'customer_bank_account_id'
  belongs_to :creditor, primary_key: 'gc_id', foreign_key: 'creditor_id'
  has_many :payments, primary_key: 'gc_id', foreign_key: 'mandate_id'
  has_many :subscriptions, primary_key: 'gc_id', foreign_key: 'mandate_id'

  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
