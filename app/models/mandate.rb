class Mandate < ActiveRecord::Base
	include Filterable

	belongs_to :customer_bank_account, primary_key: 'gc_id', foreign_key: 'customer_bank_account_id'
	delegate :customer, to: :customer_bank_account
	belongs_to :creditor, primary_key: 'gc_id', foreign_key: 'creditor_id'
	has_many :payments, primary_key: 'gc_id', foreign_key: 'mandate_id'
	has_many :subscriptions, primary_key: 'gc_id', foreign_key: 'mandate_id'

	def self.last_sync
		order('gc_created_at desc').first.gc_id
	end

  	# Returns the dropdown options for DD schemes
	def self.scheme_filters
		[
			['Any', 'any'],
			['SEPA Core', 'sepa_core'],
			['SEPA Cor1', 'sepa_cor1'],
			['UK Bacs', 'bacs'],
			['Sweden Autogiro', 'autogiro']
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
			['Any', 'any'],
			['Pending submission', 'pending_submission'],
			['Submitted', 'submitted'],
			['Active', 'active'],
			['Failed', 'failed'],
			['Cancelled', 'cancelled'],
			['Expired', 'expired'],
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
