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
end
