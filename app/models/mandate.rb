class Mandate < ActiveRecord::Base
	include Filterable

	belongs_to :customer_bank_account, primary_key: 'gc_id', foreign_key: 'customer_bank_account_id'
	delegate :customer, to: :customer_bank_account
	delegate :client, to: :customer
	belongs_to :creditor, primary_key: 'gc_id', foreign_key: 'creditor_id'
	has_many :payments, primary_key: 'gc_id', foreign_key: 'mandate_id'
	has_many :subscriptions, primary_key: 'gc_id', foreign_key: 'mandate_id'
	scope :can_take_payment,  -> { where(:status => ['pending_submission', 'submitted', 'active']) }

	def self.last_sync
		order('gc_created_at desc').first.gc_id
	end

	def customer_name
		self.customer.full_name
	end

	def next_possible_charge_date
		gc_client = GocardlessPro.new(self.customer.client.organisation)
		gc_mandate = gc_client.get_resource(self.gc_id, 'mandates')
		gc_mandate.next_possible_charge_date
	end

	def can_take_payment?
		['pending_submission', 'submitted', 'active'].include? self.status
	end

	# Cancels the mandate with GoCardless and returns a hash with the results
	def cancel
		gc_client = GocardlessPro.new(self.customer.client.organisation)
		gc_client.cancel_mandate(self.gc_id)
	end

	def currency
		case self.scheme
		when 'bacs'
			'GBP'
		when 'sepa_core'
			'EUR'
		when 'sepa_cor1'
			'EUR'
		when 'autogiro'
			'SEK'
		end
	end

  	# Returns the dropdown options for DD schemes
	def self.scheme_filters
		[
			[I18n.t('filters.scheme.any'), 'any'],
			[I18n.t('filters.scheme.sepa_core'), 'sepa_core'],
			[I18n.t('filters.scheme.sepa_cor1'), 'sepa_cor1'],
			[I18n.t('filters.scheme.bacs'), 'bacs'],
			[I18n.t('filters.scheme.autogiro'), 'autogiro']
		]
	end

	# Filters results by scheme
	def self.scheme_filter(selection)
		if selection == 'any'
			self.all
		else
			self.where('mandates.scheme = ?', selection)
		end
	end

	# Returns the dropdown options for mandate statuses
	def self.status_filters
		[
			[I18n.t('filters.mandate_status.any'), 'any'],
			[I18n.t('filters.mandate_status.pending_submission'), 'pending_submission'],
			[I18n.t('filters.mandate_status.submitted'), 'submitted'],
			[I18n.t('filters.mandate_status.active'), 'active'],
			[I18n.t('filters.mandate_status.failed'), 'failed'],
			[I18n.t('filters.mandate_status.cancelled'), 'cancelled'],
			[I18n.t('filters.mandate_status.expired'), 'expired']
		]
	end

	# Filters results by mandate status
	def self.status_filter(selection)
		if selection == 'any'
			self.all
		else
			self.where('mandates.status = ?', selection)
		end
	end
end
