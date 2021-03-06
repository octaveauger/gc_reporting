class Customer < ActiveRecord::Base
  belongs_to :client
  has_many :customer_bank_accounts, primary_key: 'gc_id', foreign_key: 'customer_id'
  has_many :mandates, through: :customer_bank_accounts
  has_many :payments, through: :mandates

  def full_name
  	if self.given_name.blank? and self.family_name.blank?
  		self.company_name
  	else
	  	company_name = (self.company_name.blank? ? '' : '(' + self.company_name.to_s + ')')
	  	self.given_name.to_s + ' ' + self.family_name.to_s + company_name
    end
  end
end
