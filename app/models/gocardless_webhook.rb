class GocardlessWebhook
	# Returns true if the signature matches, false otherwise
	def self.verify_signature(request_signature, request_body)
		begin
			require "openssl"
			digest = OpenSSL::Digest.new("sha256")
			calculated_signature = OpenSSL::HMAC.hexdigest(digest, ENV['GOCARDLESS_WEBHOOK_SECRET'], request_body)
			calculated_signature == request_signature
		rescue => e
	    	Utility.log_exception e
	    end
	end

	PROCESS_EVENTS = ['customers', 'customer_bank_accounts', 'mandates', 'payments', 'payouts', 'refunds', 'subscriptions'].freeze # types of events
	EVENT_LINKS = ['mandate', 'new_customer_bank_account', 'previous_customer_bank_account', 
		'payment', 'payout', 'refund', 'subscription'].freeze # resources that can be linked in events

	# Takes an event and process it appropriately
	def self.process_webhook_event(event)
		begin
			# oAuth: Check if organisation id is there and exists in DB
			organisation = Organisation.find_by(gc_id: event['links']['organisation'])
			return false unless !organisation.nil?

			# Already processed? Check if event exists in DB - if yes skip the rest
			event_db = Event.find_by(gc_id: event['id'])
			return false unless event_db.nil?

			# Up to date? Get resource(s) from GoCardless
			client = GocardlessPro.new(organisation)
			
			event['links'].each do |key, value|
				# Update or insert resource into DB
				if EVENT_LINKS.include?(key)
					if key == 'new_customer_bank_account' or key == 'previous_customer_bank_account'
						resource_type = 'customer_bank_accounts'
					else
						resource_type = key + 's'
					end
					resource = client.get_resource(value, resource_type)
					client.method('add_' + resource_type).call(resource.as_json) unless !PROCESS_EVENTS.include?(resource_type) or (event['resource_type'] == 'mandates' and event['action'] == 'created')
				end
			end

			# If mandate created, sync up the customer and its bank account as well
			if event['resource_type'] == 'mandates' and event['action'] == 'created'
				mandate = client.get_resource(event['links']['mandate'], 'mandates').as_json
				customer_bank_account = client.get_resource(mandate['links']['customer_bank_account'], 'customer_bank_accounts').as_json
				customer = client.get_resource(customer_bank_account['links']['customer'], 'customers').as_json
				client.add_customer_bank_accounts(customer_bank_account)
				client.add_customers(customer)
				client.add_mandates(mandate)
			end
			
			# Add event into DB
			client.add_events(event)
		rescue => e
	    	Utility.log_exception e
	    end
	end
end