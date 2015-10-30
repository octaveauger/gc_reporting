class Admin::OrganisationsController < ApplicationController
  before_action :logged_in_admin
  layout 'admin'

  def index
  	@organisations = Organisation.includes(:mandates, :payments).order('created_at desc').all.paginate(page: params[:page])
  end
end
