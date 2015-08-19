class GocardlessPro

  	def initialize(user)
		@client = GoCardlessPro::Client.new(
		  access_token: user.access_token,
		  environment: :sandbox
		)
		@user = user
	end

	def update_customers
		require 'pp'
	  	ActiveRecord::Base.transaction do
		  	params = { limit: 500 }
		  	if @user.updated?('customers')
	  			params['created_at[gt]'] = @user.last_update('customers')
	  		end
		  	
		  	@client.customers.all(params: params).each do |record|
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

		  	@user.updated('customers')
		end
	end
end