class Revenue < ActiveRecord::Base
  belongs_to :organisation

  # Returns the standard app fee (in cents/pennies) we charge when users create payments from this app
  def self.standard_app_fee(currency)
  	case currency.downcase
  	when 'gbp'
  		20
  	when 'eur'
  		20
  	when 'sek'
  		200
  	else
  		20
  	end
  end
end
