class GocardlessPro

  	def initialize(user)
		params = {}
		params[:access_token] = user.access_token
		params[:environment] = :sandbox unless Rails.env.production?
		@client = GoCardlessPro::Client.new(params)
		@user = user
	end

	SYNC_TABLES = ['customers', 'customer_bank_accounts', 'mandates', 'payments', 
		'payouts', 'refunds', 'subscriptions', 'events'].freeze # No creditos synced because this is restricted

	def sync_data
		SYNC_TABLES.each do |sync|
			self.sync_table(sync)
		end
	end

	def sync_table(sync)
		ActiveRecord::Base.transaction do
		  	params = { limit: 500 }
		  	if @user.updated?(sync)
		  		if sync == 'creditor'
	  				params['before'] = @user.creditors.last_sync unless @user.creditors.count == 0
	  			elsif sync == 'customer_bank_accounts'
	  				params['before'] = @user.customer_bank_accounts.last_sync unless @user.customer_bank_accounts.count == 0
	  			elsif sync == 'mandates'
	  				params['before'] = @user.mandates.last_sync unless @user.mandates.count == 0
	  			elsif sync == 'payouts'
	  				params['before'] = @user.payouts.last_sync unless @user.payouts.count == 0
	  			elsif sync == 'refunds'
	  				params['before'] = @user.refunds.last_sync unless @user.refunds.count == 0
	  			elsif sync == 'subscriptions'
	  				params['before'] = @user.subscriptions.last_sync unless @user.subscriptions.count == 0
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

	def add_creditors(record)
		@user.creditors.create(
			name: record.name,
			address_line1: record.address_line1,
			address_line2: record.address_line2,
			address_line3: record.address_line3,
			city: record.city,
			region: record.region,
			postal_code: record.postal_code,
			country_code: record.country_code,
			gc_id: record.id,
			gc_created_at: record.created_at)
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
			creditor_id: record.links.creditor,
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

	def add_payouts(record)
		Payout.create(
			creditor_id: record.links.creditor,
			amount: record.amount,
			currency: record.currency,
			reference: record.reference,
			status: record.status,
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	def add_refunds(record)
		Refund.create(
			payment_id: record.links.payment,
			amount: record.amount,
			currency: record.currency,
			gc_id: record.id,
			gc_created_at: record.created_at)
	end

	def add_subscriptions(record)
		Subscription.create(
			mandate_id: record.links.mandate,
			amount: record.amount,
			currency: record.currency,
			status: record.status,
			name: record.name,
			start_date: record.start_date,
			end_date: record.end_date,
			interval: record.interval,
			interval_unit: record.interval_unit,
			day_of_month: record.day_of_month,
			month: record.month,
			payment_reference: record.payment_reference,
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