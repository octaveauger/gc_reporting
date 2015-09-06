class Fee < ActiveRecord::Base
  belongs_to :event, primary_key: 'gc_id', foreign_key: 'event_id'
end
