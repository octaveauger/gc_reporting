class PayoutsController < ApplicationController
  before_action :logged_in_user

  def index
  	begin
      if params[:time_filter] and params[:time_filter] == 'between' # Handling the case of "between"
        @time_filter = 'between'
        @time_filter_from = (params[:time_filter_from].blank? ? 5.years.ago.strftime('%d/%m/%Y') : params[:time_filter_from])
        @time_filter_to = (params[:time_filter_to].blank? ? Date.tomorrow.strftime('%d/%m/%Y') : params[:time_filter_to])
        params[:time_filter] = { filter: 'between', from: @time_filter_from, to: @time_filter_to }
      else
        @time_filter = params[:time_filter] || 'any'
        @time_filter_from = nil
        @time_filter_to = nil
      end
      params_filters = params.slice(:time_filter, :currency_filter)
      @currency_filter = params[:currency_filter] || 'any'
      respond_to do |format|
        format.html do
          @payouts = current_user.payouts.filter(params_filters).includes(:events, :fees).order('gc_created_at desc').all.paginate(page: params[:page])
        end
        format.js do
          @payouts = current_user.payouts.filter(params_filters).includes(:events, :fees).order('gc_created_at desc').all.paginate(page: params[:page])
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def show
  	begin
      @payout = current_user.payouts.find_by(gc_id: params[:id])
      if @payout.nil?
        redirect_to payouts_path, alert: I18n.t('notices.payout_not_found')
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
            headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('payouts.show.csv_name') + "-" + @payout.gc_id + ".csv\""
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
