class GocardlessPro

  	def initialize(user)
		@client = GoCardlessPro::Client.new(
		  access_token: user.access_token,
		  environment: :sandbox
		)
		@user = user
	end

	SYNC_TABLES = ['customers', 'customer_bank_accounts', 'mandates', 'payments', 'events'].freeze

	def sync_data
		SYNC_TABLES.each do |sync|
			self.sync_table(sync)
		end
	end

	def sync_table(sync)
		ActiveRecord::Base.transaction do
		  	params = { limit: 500 }
		  	if @user.updated?(sync)
	  			if sync == 'customer_bank_accounts'
	  				params['before'] = @user.customer_bank_accounts.last_sync unless @user.customer_bank_accounts.count == 0
	  			elsif sync == 'mandates'
	  				params['before'] = @user.mandates.last_sync unless @user.mandates.count == 0
	  			else
	  				params['created_at[gt]'] = @user.last_update(sync)
	  			end 
	  		end
		  	
		  	@client.method(sync).call.all(params: params).each do |record|
		  		self.method('add_' + sync).call(record)
		  	end

		  	@user.updated(sync)
		end
	end

	def add_customers(record)
		@user.customers.create(
			address_line1: record.address_line1,
			address_line2: record.address_line2,
			address_line3: record.address_line3,
			city: record.city,
			company_name: record.company_name,
			country_code: record.country_code,
			email: record.email,
			given_name: record.given_name,
			family_name: record.family_name,
			postal_code: record.postal_code,
			region: record.region,
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	def add_customer_bank_accounts(record)
		CustomerBankAccount.create(
			customer_id: record.links.customer,
			account_holder_name: record.account_holder_name,
			country_code: record.country_code,
			currency: record.currency,
			bank_name: record.bank_name,
			enabled: record.enabled,
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	def add_mandates(record)
		Mandate.create(
			customer_bank_account_id: record.links.customer_bank_account,
			reference: record.reference,
			status: record.status,
			scheme: record.scheme,
			next_possible_charge_date: record.next_possible_charge_date,
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	def add_payments(record)
		Payment.create(
			mandate_id: record.links.mandate,
			charge_date: record.charge_date,
			amount: record.amount,
			description: record.description,
			currency: record.currency,
			status: record.status,
			reference: record.reference,
			amount_refunded: record.amount_refunded,
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	def add_events(record)
		links = cleanup_event_links(record.links)
		Event.create(
			resource_type: record.resource_type,
			action: record.action,
			origin: record.details['origin'],
			cause: record.details['cause'],
			description: record.details['description'],
			scheme: record.details['scheme'],
			reason_code: record.details['reason_code'],
			payment_id: links['payment'],
			mandate_id: links['mandate'],
			payout_id: links['payout'],
			refund_id: links['refund'],
			subscription_id: links['subscription'],
			new_customer_bank_account_id: links['new_customer_bank_account'],
			previous_customer_bank_account_id: links['previous_customer_bank_account'],
			parent_event_id: links['parent_event'],
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	#Placeholder until Pro client links bug is fixed - does not include new and previous bank account links as they're unrecognisable using this method
	def cleanup_event_links(dirty_links)
		clean_links = {}
		dirty_links.each do |resource|
			if !resource.nil?
				case resource[0..1]
				when 'PM'
					clean_links['payment'] = resource
				when 'MD'
					clean_links['mandate'] = resource
				when 'SB'
					clean_links['subscription'] = resource
				when 'EV'
					clean_links['parent_event'] = resource
				when 'PO'
					clean_links['payout'] = resource
				when 'RF'
					clean_links['refund'] = resource
				end
			end
		end
		clean_links
	end

end