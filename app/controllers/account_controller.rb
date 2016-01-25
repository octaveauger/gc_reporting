class AccountController < ApplicationController
  before_action :logged_in_user
  layout 'backend'

  def index
  	@account = current_user
  end
end
