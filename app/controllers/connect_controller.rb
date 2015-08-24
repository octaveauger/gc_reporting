class ConnectController < ApplicationController
  READ_ONLY = 'read_only'.freeze

  def authorise
  	auth_url = oauth.auth_code.authorize_url(
  		redirect_uri: ENV['GOCARDLESS_REDIRECT_URI'],
  		scope: READ_ONLY
  	)
  	redirect_to auth_url
  end

  def callback
  	if params[:error].present?
  		case params[:error]
  		when 'access_denied' then
  			return redirect_to root_path, notice: 'You have cancelled the authorisation flow with GoCardless'
  		else
  			return redirect_to root_path, notice: 'There was an issue with the connection to GoCardless: #{params[:error_description]}'
  		end
  	end

  	token = oauth.auth_code.get_token(params[:code],
  		redirect_uri: ENV['GOCARDLESS_REDIRECT_URI'])
  	Organisation.find_or_create_by(
  		gc_id: token['organisation_id'],
  		access_token: token.token)
  	session[:gc_token] = token.token

  	redirect_to gocardless_path
  end

  def logout
  	session[:gc_token] = nil
  	redirect_to root_path, notice: 'You have been logged out successfully'
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
