class ConnectController < ApplicationController
  READ_ONLY = 'read_only'.freeze
  FULL_ACCESS = 'full_access'.freeze

  def authorise
  	auth_url = oauth.auth_code.authorize_url(
  		redirect_uri: ENV['GOCARDLESS_REDIRECT_URI'],
  		scope: FULL_ACCESS,
      initial_view: 'login'
  	)
  	redirect_to auth_url
  end

  def callback
  	begin
      if params[:error].present?
    		case params[:error]
    		when 'access_denied' then
    			return redirect_to root_path, notice: I18n.t('errors.gocardless.auth_cancelled')
    		else
    			return redirect_to root_path, notice: I18n.t('errors.gocardless.auth_failed', error_description: params[:error_description])
    		end
    	end

    	token = oauth.auth_code.get_token(params[:code],
    		redirect_uri: ENV['GOCARDLESS_REDIRECT_URI'])
    	org = Organisation.find_by(gc_id: token['organisation_id'])
      if org.nil?
        org = Organisation.create!(
      		gc_id: token['organisation_id'],
      		access_token: token.token
        )
      elsif org.access_token != token.token
        org.update!(
          access_token: token.token
        )
      end
    	session[:gc_token] = token.token

      SyncerJob.new.async.perform(current_user)
      redirect_to after_sign_in_path
    rescue => e
      Utility.log_exception e
      redirect_to root_path, alert: I18n.t('errors.exceptions.default')
    end
  end

  def logout
  	session[:gc_token] = nil
  	redirect_to root_path, notice: I18n.t('notices.logged_out')
  end

  private

  	def oauth
  		@oauth ||= OAuth2::Client.new(
  			ENV['GOCARDLESS_CLIENT_ID'],
  			ENV['GOCARDLESS_CLIENT_SECRET'],
  			site: ENV['GOCARDLESS_CONNECT_URL'],
  			authorize_url: ENV['GOCARDLESS_AUTHORIZE_PATH'],
  			token_url: ENV['GOCARDLESS_TOKEN_PATH']
  		)
  	end
end
