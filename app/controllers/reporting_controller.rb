class ReportingController < ApplicationController
  def index
    redirect_to reporting_payments_path
  end

  def payments
    begin
      respond_to do |format|
    		format.html do
    			@payments = Payment.includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
    		end
    		format.csv do
    			@payments = Payment.includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all
    			headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('reporting.payments.csv_name') +".csv\""
    			headers['Content-Type'] ||= 'text/csv'
    		end
    	end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def payouts
    begin
      @payouts = Payout.includes(:events, :fees).order('gc_created_at desc').all.paginate(page: params[:page])
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def payout
    @payout = current_user.payouts.find_by(gc_id: params[:payout_gc_id])
    redirect_to reporting_payouts_path, alert: 'This payout could not be found' if @payout.nil?
    
  end
end
