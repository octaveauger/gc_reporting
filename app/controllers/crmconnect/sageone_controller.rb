class Crmconnect::SageoneController < ApplicationController
  before_action :logged_in_user

  def authorise
	SageOne.configure do |c|
		c.client_id     = ENV['SAGEONE_CLIENT_ID']
		c.client_secret = ENV['SAGEONE_CLIENT_SECRET']
	end

	redirect_to SageOne.authorize_url(callback_crmconnect_sageone_url)
  end

  def callback
  	response = SageOne.get_access_token(params[:code], 'https://www.example.com/your_callback_url')
	User.save_access_token(response.access_token) unless response.access_token.nil?
  end
end
