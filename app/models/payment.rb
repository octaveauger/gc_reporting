class Payment < ActiveRecord::Base
  belongs_to :mandate, primary_key: 'gc_id', foreign_key: 'mandate_id'
  delegate :customer_bank_account, to: :mandate
  delegate :customer, to: :customer_bank_account
  has_many :events, primary_key: 'gc_id', foreign_key: 'payment_id'

  def failure_cause
    self.status == 'failed' ? self.events.where(action: 'failed').first.cause : ''
  end

  # A user friendly overview of payments with their customer name etc,
  def self.overview
  	#results = { , records: [] }
  	results = {}
  	headers = { id: 'Payment ID', created_at: 'Payment creation date', customer_id: 'Customer ID', first_name: 'First name', last_name: 'Last name',
  		company_name: 'Company name', email: 'Email', description: 'Description', charge_date: 'Expected charge date', amount: 'Amount',
  		amount_refunded: 'Amount refunded', currency: 'Currency', reference: 'Reference', status: 'status' }
  	self.where('payments.id < 5').each do |payment|
  		results[payment.id] = {
  			id: payment.gc_id,
  			created_at: payment.gc_created_at,
  			customer_id: payment.customer.gc_id,
  			first_name: payment.customer.given_name,
  			last_name: payment.customer.family_name,
  			company_name: payment.customer.company_name,
  			email: payment.customer.email,
  			description: payment.description,
  			charge_date: payment.charge_date,
  			amount: payment.amount,
  			amount_refunded: payment.amount_refunded,
  			currency: payment.currency,
  			reference: payment.reference,
  			status: payment.status
  		}
  	end
  	{ records: results, headers: headers }
  end

end
