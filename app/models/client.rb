class Client < ActiveRecord::Base
  include Tokenable
  include Filterable

  belongs_to :client_source
  belongs_to :organisation
  has_many :customers
  has_many :customer_bank_accounts, through: :customers
  has_many :mandates, through: :customer_bank_accounts
  has_many :payments, through: :mandates
  has_many :events, through: :payments
  has_many :refunds, through: :payments
  has_many :subscriptions, through: :mandates

  def full_name
  	self.fname.to_s + ' ' + self.lname.to_s
  end

  def display_name
  	if self.fname.blank? and self.lname.blank?
  		self.company_name
  	else
	  	company_name = (self.company_name.blank? ? '' : '(' + self.company_name.to_s + ')')
	  	self.fname.to_s + ' ' + self.lname.to_s + company_name
    end
  end
end
