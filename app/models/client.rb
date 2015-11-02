class Client < ActiveRecord::Base
  belongs_to :client_source
  belongs_to :organisation
  has_one :customer
end
