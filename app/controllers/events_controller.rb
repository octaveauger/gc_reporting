class EventsController < ApplicationController
  before_action :logged_in_user
  layout 'backend'

  def payouts
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
      params_filters = params.slice(:time_filter)
      payouts = current_user.payouts.filter(params_filters).all.map { |p| p.gc_id }.uniq
      parent_events = Event.where(payout_id: payouts).where(action: 'paid').all.map { |e| e.gc_id }.uniq
      respond_to do |format|
        format.html do
          @events = Event.where(parent_event_id: parent_events).includes(:payment, :refund).order('events.gc_created_at desc').all.paginate(page: params[:page])
          @statistics = Event.statistics_payouts(payouts)
        end
        format.js do
          @events = Event.where(parent_event_id: parent_events).includes(:payment, :refund).order('events.gc_created_at desc').all.paginate(page: params[:page])
        end
        format.csv do
          @events = Event.where(parent_event_id: parent_events).includes(:payment, :refund).order('events.gc_created_at desc').all
          headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('events.payouts.csv_name') + ".csv\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end
end
