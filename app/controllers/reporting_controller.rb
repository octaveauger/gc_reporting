class ReportingController < ApplicationController
  before_action :logged_in_user

  def index
    redirect_to reporting_mandates_path
  end

  def mandates
    begin
      params_filters = params.slice(:time_filter, :scheme_filter, :status_filter)
      @time_filter = params[:time_filter] || 'any'
      @scheme_filter = params[:scheme_filter] || 'any'
      @status_filter = params[:status_filter] || 'any'
      respond_to do |format|
        format.html do
          @mandates = current_user.mandates.filter(params_filters).includes(:customer_bank_account, { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
        end
        format.js do
          @mandates = current_user.mandates.filter(params_filters).includes(:customer_bank_account, { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
        end
        format.csv do
          @mandates = current_user.mandates.filter(params_filters).includes(:customer_bank_account, { customer_bank_account: :customer }).order('gc_created_at desc').all
          headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('reporting.mandates.csv_name') + ".csv\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def payments
    begin
      @time_filter = params[:time_filter] || 'any'
      respond_to do |format|
    		format.html do
    			@payments = current_user.payments.filter(params.slice(:time_filter)).includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
    		end
        format.js do
          @payments = current_user.payments.filter(params.slice(:time_filter)).includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
        end
    		format.csv do
    			@payments = current_user.payments.filter(params.slice(:time_filter)).includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all
    			headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('reporting.payments.csv_name') + ".csv\""
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
      @time_filter = params[:time_filter] || 'any'
      respond_to do |format|
        format.html do
          @payouts = current_user.payouts.filter(params.slice(:time_filter)).includes(:events, :fees).order('gc_created_at desc').all.paginate(page: params[:page])
        end
        format.js do
          @payouts = current_user.payouts.filter(params.slice(:time_filter)).includes(:events, :fees).order('gc_created_at desc').all.paginate(page: params[:page])
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def payout
    begin
      @payout = current_user.payouts.find_by(gc_id: params[:payout_gc_id])
      if @payout.nil?
        redirect_to reporting_payouts_path, alert: I18n.t('notices.payout_not_found')
      else
        @parent_event = @payout.events.where(action: 'paid').first

        respond_to do |format|
          format.html do
            @events = Event.where(parent_event_id: @parent_event.gc_id).all.paginate(page: params[:page])
          end
          format.js do
            @events = Event.where(parent_event_id: @parent_event.gc_id).all.paginate(page: params[:page])
          end
          format.csv do
            @events = Event.where(parent_event_id: @parent_event.gc_id).all
            headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('reporting.payout.csv_name') + "-" + @payout.gc_id + ".csv\""
            headers['Content-Type'] ||= 'text/csv'
          end
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end
end
