class MandatesController < ApplicationController
  before_action :logged_in_user
  layout 'backend'

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
      params_filters = params.slice(:time_filter, :scheme_filter, :status_filter)
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
          headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('mandates.index.csv_name') + ".csv\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def show
  	@mandate = current_user.mandates.find_by(gc_id: params[:id])
  	if !@mandate.nil?
  		@next_possible_charge_date = @mandate.next_possible_charge_date
  		response = {
  			currency: currency_symbol(@mandate.currency),
  			next_possible_charge_date: @next_possible_charge_date,
  			next_possible_charge_date_formatted: @next_possible_charge_date.to_date.strftime('%d/%m/%Y')
  		}
  	end
  	respond_to do |format|
  		format.json { render json: response }
    end
  end

  def cancel
    @mandate = current_user.mandates.find_by(gc_id: params['mandate_id'])
    if !@mandate.nil?
      @results = @mandate.cancel
      @cancelled = @results[:success]
    end
    respond_to do |format|
      format.js
    end
  end
end
