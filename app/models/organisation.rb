class Organisation < ActiveRecord::Base
	has_many :clients
	has_many :customers, through: :clients
	has_many :customer_bank_accounts, through: :customers
	has_many :mandates, through: :customer_bank_accounts
	has_many :payments, through: :mandates
	has_many :events, through: :payments
	has_many :payouts, through: :creditors
	has_many :refunds, through: :payments
	has_many :subscriptions, through: :mandates
	has_many :organisation_updates
	has_many :creditors
	has_many :revenues

	validates :email, format: /.+@.+\..+/i, allow_nil: true

	def updated?(cat)
		self.organisation_updates.where(category: cat).count > 0
	end

	def last_update(cat)
		self.updated?(cat) ? self.organisation_updates.find_by(category: cat).last_update.iso8601 : nil
	end

	def updated(cat)
		row = self.organisation_updates.find_by(category: cat)
		if row.nil?
			self.organisation_updates.create(category: cat, last_update: Time.current)
		else
			row.update(last_update: Time.current)
		end
	end

	def recent_update?
		['customers', 'customer_bank_accounts', 'mandates', 'payments', 
			'payouts', 'refunds', 'subscriptions', 'events'].reverse_each do |cat|
			update = self.organisation_updates.where(category: cat).first
			return false unless !update.nil?
		end
		true
	end

	# Returns true if all fields are complete, false otherwise
	def profile_complete?
		!self.fname.blank? and !self.lname.blank? and !self.email.blank? and !self.company_name.blank? and !self.country.blank? and !self.locale.blank?
	end

	def full_name
		self.fname.to_s + ' ' + self.lname.to_s
	end

	def display_name
		if self.company_name.blank?
			self.full_name
		else
			self.company_name
		end
	end

	def client_count
		self.clients.count
	end

	def mandate_count
		self.mandates.count
	end

	def payment_count
		self.payments.count
	end
end
