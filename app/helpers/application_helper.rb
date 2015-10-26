module ApplicationHelper
	# Returns a HMTL friendly symbol for major currencies
	# Source: http://character-code.com/currency-html-codes.php and http://www.xe.com/iso4217.php
	def currency_symbol(currency)
	  	case currency.downcase
	  	when 'eur'
	  		'&euro;'.html_safe
	  	when 'gbp'
	  		'&pound;'.html_safe
	  	when 'usd'
	  		'&#36;'.html_safe
	  	when 'jpy'
	  		'&yen;'.html_safe
	  	when 'chf'
	  		'&#8355;'.html_safe
	  	else currency
	  	end
	end

	# Analyses a status (from any GC object) - returns something to use in the CSS status-disc class
	def status_meaning(status)
		return 'pending' if ['pending', 'pending_submission','submitted'].include?(status)
		return 'positive' if ['active', 'confirmed', 'paid_out', 'paid'].include?(status)
		return 'negative'
	end

	# Returns the right flag css class based on the locale
	def locale_flag(locale)
		case locale
		when 'en'
			'flag-gb'
		when 'fr'
			'flag-fr'
		else
			'flag-gb'
		end
	end
end
