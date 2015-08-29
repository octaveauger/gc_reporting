class Subscription < ActiveRecord::Base
  belongs_to :mandate, primary_key: 'gc_id', foreign_key: 'mandate_id'
  
  def self.last_sync
  	order('gc_created_at desc').first.gc_id
  end
end
