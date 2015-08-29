class Organisation < ActiveRecord::Base
	has_many :customers
	has_many :customer_bank_accounts, through: :customers
	has_many :mandates, through: :customer_bank_accounts
	has_many :payments, through: :mandates
	has_many :events, through: :payments
	has_many :payouts, through: :creditors
	has_many :refunds, through: :payments
	has_many :subscriptions, through: :mandates
	has_many :organisation_updates
	has_many :creditors

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
			return false unless !update.nil? and update.last_update > 6.hours.ago
		end
		true
	end
end
