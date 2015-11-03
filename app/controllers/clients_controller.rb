class ClientsController < ApplicationController
  before_action :logged_in_user

  def index
    begin
      params_filters = params.slice(:time_filter)
      @time_filter = params[:time_filter] || 'any'
      respond_to do |format|
        format.html do
          @clients = current_user.clients.filter(params_filters).includes(:customers, :mandates).order('source_created_at desc').all.paginate(page: params[:page])
        end
        format.js do
          @clients = current_user.clients.filter(params_filters).includes(:customers, :mandates).order('source_created_at desc').all.paginate(page: params[:page])
        end
        format.csv do
          @clients = current_user.clients.filter(params_filters).includes(:customers, :mandates).order('source_created_at desc').all
          headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('clients.index.csv_name') + ".csv\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
    @client = current_user.clients.find_by(token: params[:id])
    if @client.nil?
      redirect_to reporting_path, alert: I18n.t('notices.client_not_found')
    end
    @payments = @client.payments.includes(:events).order('gc_created_at desc').all.paginate(page: params[:page])

    render layout: !request.xhr?
  end
end
