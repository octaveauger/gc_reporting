class PaymentRequest
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

	attr_accessor :mandate_id, :mandate, :amount, :currency, :description, :reference, :charge_date, :app_fee
	validates :mandate_id, presence: true
	validates :amount, presence: true, numericality: true
	validates :charge_date, presence: true, :timeliness => { :type => :date }
	validate :mandate_related_validation

	def initialize(attributes = {})
		attributes.each do |name, value|
			send("#{name}=", value)
    	end
    	self.app_fee ||= 20 # Set to 20p unless specified
    	self.mandate = Mandate.can_take_payment.find_by(gc_id: self.mandate_id)
    	self.currency = self.mandate.currency unless self.mandate.nil?
	end

	def persisted?
    	false
    end

    def mandate_related_validation
    	if self.mandate.nil?
    		errors.add(:mandate_id, 'is not valid')
    	else
    		if !self.charge_date.nil? and Time.parse(self.charge_date) < Time.parse(self.mandate.next_possible_charge_date)
    			errors.add(:charge_date, 'must be on or later than ' + mandate.next_possible_charge_date)
    		end
    		reference_max_lengths = { 'bacs' => 10, 'sepa_core' => 140, 'sepa_cor1' => 140, 'autogiro' => 16 }
    		if !self.reference.nil? and self.reference.length > reference_max_lengths[self.mandate.scheme]
    			errors.add(:reference, 'must be less than ' + reference_max_lengths[self.mandate.scheme] + 'characters')
    		end
    	end
    end

    # The data we pass to the gocardless_pro model when creating the payment
    def params_for_gocardless
    	{
    		amount: (self.amount.to_f * 100).to_i,
    		app_fee: self.app_fee,
    		charge_date: self.charge_date,
    		currency: self.currency,
    		description: self.description.to_s,
    		reference: self.reference.to_s,
    		links: {
    			mandate: self.mandate_id
    		}
    	}
    end
end
