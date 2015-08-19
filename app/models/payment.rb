class Payment < ActiveRecord::Base
  belongs_to :mandate
  has_many :payment_events
end
