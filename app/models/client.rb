class Client < ActiveRecord::Base
  include Tokenable

  belongs_to :client_source
  belongs_to :organisation
  has_many :customers
end
