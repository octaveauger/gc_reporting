class RefundRequest
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

	attr_accessor :payment_id, :payment, :amount, :total_amount_confirmation, :currency, :reference
	validates :payment_id, presence: true
	validates :amount, presence: true, numericality: true
	validate :payment_related_validation

	def initialize(attributes = {})
		attributes.each do |name, value|
			send("#{name}=", value)
    	end
    	self.payment = Payment.can_be_refunded.find_by(gc_id: self.payment_id)
    	self.currency = self.payment.currency unless self.payment.nil?
        self.total_amount_confirmation = self.amount.to_i * 100 + self.payment.total_refunded_amount
	end

	def persisted?
    	false
    end

    def payment_related_validation
    	if self.payment.nil?
    		errors.add(:payment_id, 'is not valid')
    	else
            if self.amount.to_i > self.payment.max_refundable_amount / 100
                errors.add(:amount, :too_much)
            elsif self.amount.to_i < 1 # At least €/£1
                errors.add(:amount, :too_little)
            end
            reference_max_lengths = { 'bacs' => 18, 'sepa_core' => 140, 'sepa_cor1' => 140, 'autogiro' => 25 }
            if !self.reference.nil? and self.reference.length > reference_max_lengths[self.payment.mandate.scheme]
                errors.add(:reference, :too_long, chars: reference_max_lengths[self.payment.mandate.scheme].to_s)
            end
    	end
    end

    # The data we pass to the gocardless_pro model when creating the refund
    def params_for_gocardless
    	{
    		amount: (self.amount.to_f * 100).to_i,
    		total_amount_confirmation: self.total_amount_confirmation,
    		reference: self.reference.to_s,
    		links: {
    			payment: self.payment_id
    		}
    	}
    end
end
