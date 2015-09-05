class Payout < ActiveRecord::Base
  belongs_to :creditor, primary_key: 'gc_id', foreign_key: 'creditor_id'
  has_many :events, primary_key: 'gc_id', foreign_key: 'payout_id'
  
  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
