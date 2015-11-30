class AccountController < ApplicationController
  before_action :logged_in_user

  def index
  	@account = current_user
  end
end
