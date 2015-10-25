class Payment < ActiveRecord::Base
	include Filterable

	belongs_to :mandate, primary_key: 'gc_id', foreign_key: 'mandate_id'
	delegate :customer_bank_account, to: :mandate
	delegate :customer, to: :customer_bank_account
	has_many :events, primary_key: 'gc_id', foreign_key: 'payment_id'
	has_many :refunds, primary_key: 'gc_id', foreign_key: 'payment_id'
	scope :can_be_refunded,  -> { where(:status => ['confirmed', 'paid_out']) }

	def failure_cause
		if self.status == 'failed' and self.events.where(action: 'failed').any?
			self.events.where(action: 'failed').first.cause
		else
			''
		end
	end

	def customer_name
		self.mandate.customer_name
	end

	def can_be_cancelled?
		self.status == 'pending_submission'
	end

	def can_be_retried?
		self.mandate.can_take_payment? and self.status == 'failed'
	end

	def can_be_refunded?
		['confirmed', 'paid_out'].include? self.status
	end

	def total_refunded_amount
		total = 0
		self.refunds.each do |refund|
			total += refund.amount.to_i
		end
		total
	end

	def max_refundable_amount
		self.amount - self.total_refunded_amount
	end

	# Cancels the payment with GoCardless and returns a hash with the results
	def cancel
		client = GocardlessPro.new(self.customer.organisation)
		client.cancel_payment(self.gc_id)
	end

	# Retries the payment with GoCardless and returns a hash with the results
	def retry
		client = GocardlessPro.new(self.customer.organisation)
		client.retry_payment(self.gc_id)
	end

  	# Returns the dropdown options for payment statuses
	def self.status_filters
		[
			[I18n.t('filters.payment_status.any'), 'any'],
			[I18n.t('filters.payment_status.pending_submission'), 'pending_submission'],
			[I18n.t('filters.payment_status.submitted'), 'submitted'],
			[I18n.t('filters.payment_status.confirmed'), 'confirmed'],
			[I18n.t('filters.payment_status.paid_out'), 'paid_out'],
			[I18n.t('filters.payment_status.failed'), 'failed'],
			[I18n.t('filters.payment_status.cancelled'), 'cancelled'],
			[I18n.t('filters.payment_status.charged_back'), 'charged_back']
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
