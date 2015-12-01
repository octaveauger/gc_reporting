class ClientsController < ApplicationController
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
      params_filters = params.slice(:time_filter, :valid_mandate_filter)
      @valid_mandate_filter = params[:valid_mandate_filter] || 'any'
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
    @client = current_user.clients.new
  end

  def create
    @client = current_user.clients.new(client_params)
    @client.assign_attributes(
      source_created_at: Time.now,
      client_source_id: ClientSource.find_by(name: 'import').id
    )
    if @client.save
      redirect_to new_client_path, notice: I18n.t('clients.new.client_success') and return
    else
      flash[:alert] = I18n.t('errors.form.please_correct_form')
      render 'new'
    end
  end

  def edit
    @client = current_user.clients.find_by(token: params[:id])
    if @client.nil?
      redirect_to clients_path, alert: I18n.t('notices.invalid_link') and return
    end
  end

  def update
    @client = current_user.clients.find_by(token: params[:id])
    if @client.update_attributes(client_params)
      redirect_to clients_path, notice: I18n.t('clients.edit.client_success') and return
    else
      flash[:alert] = I18n.t('errors.form.please_correct_form')
      render 'edit'
    end
  end

  def show
    @client = current_user.clients.find_by(token: params[:id])
    if @client.nil?
      redirect_to clients_path, alert: I18n.t('notices.client_not_found') and return
    end
    @payments = @client.payments.includes(:events).order('gc_created_at desc').all.paginate(page: params[:page])

    render layout: !request.xhr?
  end

  def new_pending
    @clients = PendingClient.new(locale: I18n.locale.to_s)
  end

  def create_pending
    @clients = PendingClient.new(pending_client_params)
    @results = @clients.create_clients(current_user)
    if @results[:full_success]
      redirect_to clients_path, notice: I18n.t('clients.new_pending.client_success') and return
    else
      flash[:alert] = I18n.t('errors.form.please_correct_form')
      render 'new_pending'
    end
  end

  def mandate_link
  end

  def email_mandate
    @client = current_user.clients.find_by(token: params[:client_id])
    if !@client.nil?
      @client.update_mandate_request_date
      @client.save
      @client.email_mandate_request
    end
    respond_to do |format|
      format.js
    end
  end

  private

    def client_params
      params.require(:client).permit(:fname, :lname, :email, :company_name, :source_client_id, :locale, :mandate_request_description, :request_mandate)
    end

    def pending_client_params
      params.require(:pending_client).permit(:emails, :locale, :mandate_request_description)
    end
end
