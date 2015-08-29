class Creditor < ActiveRecord::Base
  belongs_to :organisation
  has_many :mandates, primary_key: 'gc_id', foreign_key: 'creditor_id'
  has_many :payouts, primary_key: 'gc_id', foreign_key: 'creditor_id'
  
  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
