class ReportingController < ApplicationController
  def index
  end

  def payments
    begin
      respond_to do |format|
    		format.html do
    			@payments = Payment.includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
    		end
    		format.csv do
    			@payments = Payment.includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all
    			headers['Content-Disposition'] = "attachment; filename=\"payment-list.csv\""
    			headers['Content-Type'] ||= 'text/csv'
    		end
    	end
    rescue => e
      Utility.log_exception e
      flash[:alert] = "Something went wrong and we've been notified"
    end
  end
end
