class MailerClientJob 
  include SuckerPunch::Job
  workers 2
    
  def perform(client, email_type)
  	case email_type # we can't use OrgClientMailer.method(email_type).call(client).deliver - see http://stackoverflow.com/questions/17088619/how-can-you-call-class-methods-on-mailers-when-theyre-not-defined-as-such
  	when 'mandate_request'
  		OrgClientMailer.mandate_request(client).deliver
  	end
  end
end
