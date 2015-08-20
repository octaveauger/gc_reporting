class Organisation < ActiveRecord::Base
	has_many :customers
	has_many :customer_bank_accounts, through: :customers
	has_many :mandates, through: :customer_bank_accounts
	has_many :payments, through: :mandates
	has_many :events, through: :payments
	has_many :organisation_updates

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
end
