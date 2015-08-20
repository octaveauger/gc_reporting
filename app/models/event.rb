class Event < ActiveRecord::Base
  belongs_to :payment, primary_key: 'gc_id', foreign_key: 'payment_id'
end
