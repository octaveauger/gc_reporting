class Payment < ActiveRecord::Base
	include Filterable

	belongs_to :mandate, primary_key: 'gc_id', foreign_key: 'mandate_id'
	delegate :customer_bank_account, to: :mandate
	delegate :customer, to: :customer_bank_account
	has_many :events, primary_key: 'gc_id', foreign_key: 'payment_id'
	has_many :refunds, primary_key: 'gc_id', foreign_key: 'payment_id'

	def failure_cause
		self.status == 'failed' ? self.events.where(action: 'failed').first.cause : ''
	end

  	# Returns the dropdown options for payment statuses
	def self.status_filters
		[
			['Any', 'any'],
			['Pending submission', 'pending_submission'],
			['Submitted', 'submitted'],
			['Confirmed', 'confirmed'],
			['Paid out', 'paid_out'],
			['Failed', 'failed'],
			['Cancelled', 'cancelled'],
			['Charged back', 'charged_back']
		]
	end

	# Filters results by payment status
	def self.status_filter(selection)
		if selection == 'any'
			self.all
		else
			self.where('payments.status = ?', selection)
		end
	end
end
