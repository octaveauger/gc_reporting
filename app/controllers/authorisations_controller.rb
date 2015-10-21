class AuthorisationsController < ApplicationController
  layout 'stripped'

  def new
  	org = Organisation.find_by(gc_id: params['flow_id'])
  	if org.nil?
  		redirect_to authorisations_error_path, alert: I18n.t('notices.invalid_link')
	else
	  	client = GocardlessPro.new(org)
	  	redirect_flow = client.create_redirect_flow(redirect_flow_session_token, authorisations_confirm_url(params['flow_id']))
	  	if redirect_flow[:success]
	  		redirect_to redirect_flow[:flow_link]
	  	else
	  		redirect_to authorisations_error_path, alert: 'GoCardless: ' + redirect_flow[:message]
	  	end
	end
  end

  def confirm
  	org = Organisation.find_by(gc_id: params['flow_id'])
  	if org.nil?
  		redirect_to authorisations_error_path, alert: I18n.t('notices.invalid_link')
  	else
	  	client = GocardlessPro.new(org)
	  	redirect_flow = client.complete_redirect_flow(params['redirect_flow_id'], redirect_flow_session_token)
	  	delete_redirect_flow_session_token
	  	if redirect_flow[:success]
	  		redirect_to authorisations_success_path, notice: I18n.t('notices.mandate_success')
	  	else
	  		redirect_to authorisations_error_path, alert: 'GoCardless: ' + redirect_flow[:message]
	  	end
	end
  end

  def error
  end

  def success
  end
end
