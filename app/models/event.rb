class Event < ActiveRecord::Base
  belongs_to :payment, primary_key: 'gc_id', foreign_key: 'payment_id'
  belongs_to :refund, primary_key: 'gc_id', foreign_key: 'refund_id'
  has_one :fee, primary_key: 'gc_id', foreign_key: 'event_id'
end
