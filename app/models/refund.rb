class Refund < ActiveRecord::Base
  belongs_to :payment, primary_key: 'gc_id', foreign_key: 'payment_id'
  
  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
