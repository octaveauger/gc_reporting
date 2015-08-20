class Payment < ActiveRecord::Base
  belongs_to :mandate, primary_key: 'gc_id', foreign_key: 'mandate_id'
  has_many :events, primary_key: 'gc_id', foreign_key: 'payment_id'
end
