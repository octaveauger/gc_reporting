class CustomersController < ApplicationController
  before_action :logged_in_user

  def show
  	@customer = current_user.customers.find_by(id: params[:id])
  	if @customer.nil?
  		redirect_to reporting_path, alert: I18n.t('notices.customer_not_found')
  	end
  	@payments = @customer.payments.includes(:events).order('gc_created_at desc').all.paginate(page: params[:page])

  	render layout: !request.xhr?
  end
end
