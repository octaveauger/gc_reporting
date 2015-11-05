class MailerClientJob 
  include SuckerPunch::Job
  workers 2
    
  def perform(client, email_type)
  	#OrgClientMailer.method(email_type).call(client).deliver
  	OrgClientMailer.mandate_request(client).deliver
  end
end
