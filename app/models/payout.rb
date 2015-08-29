class Payout < ActiveRecord::Base
  belongs_to :creditor, primary_key: 'gc_id', foreign_key: 'creditor_id'
  
  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
