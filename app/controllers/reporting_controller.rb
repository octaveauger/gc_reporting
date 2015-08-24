class ReportingController < ApplicationController
  def index
  end

  def payments
  	@payments = Payment.includes(:events, mandate: { customer_bank_account: :customer }).all.paginate(page: params[:page])
  	respond_to do |format|
  		format.html
  		format.csv do
  			headers['Content-Disposition'] = "attachment; filename=\"payment-list.csv\""
  			headers['Content-Type'] ||= 'text/csv'
  		end
  	end
  end
end
