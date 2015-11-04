class WebhookController < ApplicationController
  skip_before_filter  :verify_authenticity_token, :authenticate_user!

  def index
  	request_signature = request.headers['Webhook-Signature']
  	request_body = request.body.read
  	if GocardlessWebhook.verify_signature(request_signature, request_body)
  		begin
        JSON.parse(request_body)['events'].each do |event|
          GocardlessWebhook.process_webhook_event(event)
    		end
    		render :status => 204
      rescue
        render :status => 500
      end
  	else
  		render :status => 498
  	end
  end
end
