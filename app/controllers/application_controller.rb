class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApplicationHelper
  include SessionHelper
  require 'csv'

  before_filter :redirect_to_custom_domain

  private

  	def redirect_to_custom_domain
		redirect_to("https://www.antilope.io", status: 301) if request.host == 'gc-reporting.herokuapp.com'
	end
end
