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
		begin
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
			  		self.method('add_' + sync).call(record.as_json)
			  	end

			  	@user.updated(sync)
			end
		rescue => e
	    	Utility.log_exception e
	    	flash[:alert] = "Something went wrong and we've been notified"
	    end
	end

	# Gets a single resource based on the GC id and its type (plural, e.g 'payments')
	def get_resource(id, type)
		@client.method(type).call.get(id)
	end

	def add_creditors(creditor_gc_id)
		params = { gc_id: creditor_gc_id }
		creditor = @user.creditors.find_by(gc_id: creditor_gc_id)
		if creditor.nil?
			creditor = @user.creditors.create(params)
		else
			creditor.update(params)
		end
		creditor
	end

	def add_customers(record)
		params = { 
			address_line1: record['address_line1'],
			address_line2: record['address_line2'],
			address_line3: record['address_line3'],
			city: record['city'],
			company_name: record['company_name'],
			country_code: record['country_code'],
			email: record['email'],
			given_name: record['given_name'],
			family_name: record['family_name'],
			postal_code: record['postal_code'],
			region: record['region'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		customer = @user.customers.find_by(gc_id: record['id'])
		if customer.nil?
			@user.customers.create(params)
		else
			customer.update(params)
		end
	end

	def add_customer_bank_accounts(record)
		params = {
			customer_id: record['links']['customer'],
			account_holder_name: record['account_holder_name'],
			country_code: record['country_code'],
			currency: record['currency'],
			bank_name: record['bank_name'],
			enabled: record['enabled'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		customer_bank_account = @user.customer_bank_accounts.find_by(gc_id: record['id'])
		if customer_bank_account.nil?
			CustomerBankAccount.create(params)
		else
			customer_bank_account.update(params)
		end
	end

	def add_mandates(record)
		params = {
			customer_bank_account_id: record['links']['customer_bank_account'],
			creditor_id: record['links']['creditor'],
			reference: record['reference'],
			status: record['status'],
			scheme: record['scheme'],
			next_possible_charge_date: record['next_possible_charge_date'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		mandate = @user.mandates.find_by(gc_id: record['id'])
		if mandate.nil?
			Mandate.create(params)
		else
			mandate.update(params)
		end
	end

	def add_payments(record)
		params = {
			mandate_id: record['links']['mandate'],
			charge_date: record['charge_date'],
			amount: record['amount'],
			description: record['description'],
			currency: record['currency'],
			status: record['status'],
			reference: record['reference'],
			amount_refunded: record['amount_refunded'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		payment = @user.payments.find_by(gc_id: record['id'])
		if payment.nil?
			Payment.create(params)
		else
			payment.update(params)
		end
	end

	def add_payouts(record)
		creditor = self.add_creditors(record['links']['creditor']) # As long as Creditor endpoint not available by oAuth apps, we add them manually
		params = {
			creditor_id: record['links']['creditor'],
			amount: record['amount'],
			currency: record['currency'],
			reference: record['reference'],
			status: record['status'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		payout = @user.payouts.find_by(gc_id: record['id'])
		if payout.nil?
			Payout.create(params)
		else
			payout.update(params)
		end
	end

	def add_refunds(record)
		params = {
			payment_id: record['links']['payment'],
			amount: record['amount'],
			currency: record['currency'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		refund = @user.refunds.find_by(gc_id: record['id'])
		if refund.nil?
			Refund.create(params)
		else
			refund.update(params)
		end
	end

	def add_subscriptions(record)
		params = {
			mandate_id: record['links']['mandate'],
			amount: record['amount'],
			currency: record['currency'],
			status: record['status'],
			name: record['name'],
			start_date: record['start_date'],
			end_date: record['end_date'],
			interval: record['interval'],
			interval_unit: record['interval_unit'],
			day_of_month: record['day_of_month'],
			month: record['month'],
			payment_reference: record['payment_reference'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		subscription = @user.subscriptions.find_by(gc_id: record['id'])
		if subscription.nil?
			Subscription.create(params)
		else
			subscription.update(params)
		end
	end

	def add_events(record)
		params = {
			resource_type: record['resource_type'],
			action: record['action'],
			origin: record['details']['origin'],
			cause: record['details']['cause'],
			description: record['details']['description'],
			scheme: record['details']['scheme'],
			reason_code: record['details']['reason_code'],
			payment_id: record['links']['payment'],
			mandate_id: record['links']['mandate'],
			payout_id: record['links']['payout'],
			refund_id: record['links']['refund'],
			subscription_id: record['links']['subscription'],
			new_customer_bank_account_id: record['links']['new_customer_bank_account'],
			previous_customer_bank_account_id: record['links']['previous_customer_bank_account'],
			parent_event_id: record['links']['parent_event'],
			gc_id: record['id'],
			gc_created_at: record['created_at']
		}
		event = @user.events.find_by(gc_id: record['id'])
		if event.nil?
			event = Event.create(params)
		else
			event.update(params)
		end

		# If fees are due because this event is about a payout
		if (
				event.resource_type == 'payments' and 
				['paid_out', 'late_failure_settled', 'chargeback_settled'].include? (event.action)
			) or (
				event.resource_type == 'refunds' and
				event.action == 'refund_settled'
			)
			self.add_fees(event)
		end
	end

	def add_fees(event)
		case event.action
			when 'paid_out'
				Fee.create(event_id: event.gc_id, amount: [200, event.payment.amount * 0.01].min, currency: event.payment.currency)
			when 'late_failure_settled'
				Fee.create(event_id: event.gc_id, amount: -[200, event.payment.amount * 0.01].min, currency: event.payment.currency)
			when 'chargeback_settled'
				Fee.create(event_id: event.gc_id, amount: 0, currency: event.payment.currency)
			when 'refund_settled'
				Fee.create(event_id: event.gc_id, amount: 0, currency: event.refund.currency)
		end
	end

end