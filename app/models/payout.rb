class Payout < ActiveRecord::Base
  belongs_to :creditor, primary_key: 'gc_id', foreign_key: 'creditor_id'
  has_many :events, primary_key: 'gc_id', foreign_key: 'payout_id'
  has_many :payments, through: :events
  has_many :refunds, through: :events
  has_many :fees, through: :events
  
  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
  
  def sum_fees
  	sum = 0
  	self.fees.each do |fee|
  		sum += fee.amount
  	end
  	sum
  end
end
