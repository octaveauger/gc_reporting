class CustomerBankAccount < ActiveRecord::Base
  belongs_to :customer
  has_many :mandates
end
