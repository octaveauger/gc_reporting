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
