# Tableless model to manage the creation of many clients based on their emails
class PendingClient
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

	attr_accessor :emails, :locale, :mandate_request_description
	validates :emails, presence: true
	validates :locale, presence: true

	def initialize(attributes = {})
		attributes.each do |name, value|
			send("#{name}=", value)
    	end
	end

	def persisted?
    	false
    end

    # Generates all clients and returns a hash with true for emails that were created and false for those that weren't
    def create_clients(organisation)
        valid_clients = []
        invalid_emails = []
        results = {}
        all_good = true
        client_source = ClientSource.find_by(name: 'import').id
        # Check the validity of each email
        self.emails.split(',').uniq.each do |email|
            client = Client.new(
                organisation_id: organisation.id,
                email: email,
                locale: self.locale,
                mandate_request_description: self.mandate_request_description,
                request_mandate: true,
                source_created_at: Time.now,
                client_source_id: client_source
            )
            if client.valid?
                results[email] = true
                valid_clients.push(client)
            else
                results[email] = false
                invalid_emails.push(email)
                all_good = false
            end
        end
        if all_good # create all clients
            valid_clients.each do |client|
                client.save
            end
        else # prepare the error message
            errors.add(:emails, :invalid_emails, emails: invalid_emails.join(', '))
            self.remove_invalid_emails(invalid_emails)
        end
        { results: results, full_success: all_good }
    end

    def remove_invalid_emails(invalid_emails)
        self.emails = (self.emails.split(',').uniq - invalid_emails).join(',')
    end
end
