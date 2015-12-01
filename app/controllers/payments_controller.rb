class PaymentsController < ApplicationController
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
      params_filters = params.slice(:time_filter, :currency_filter, :status_filter)
      @currency_filter = params[:currency_filter] || 'any'
      @status_filter = params[:status_filter] || 'any'
      respond_to do |format|
        format.html do
          @payments = current_user.payments.filter(params_filters).includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
        end
        format.js do
          @payments = current_user.payments.filter(params_filters).includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all.paginate(page: params[:page])
        end
        format.csv do
          @payments = current_user.payments.filter(params_filters).includes(:events, mandate: { customer_bank_account: :customer }).order('gc_created_at desc').all
          headers['Content-Disposition'] = "attachment; filename=\"" + I18n.t('payments.index.csv_name') + ".csv\""
          headers['Content-Type'] ||= 'text/csv'
        end
      end
    rescue => e
      Utility.log_exception e
      flash[:alert] = I18n.t('errors.exceptions.default')
    end
  end

  def show
    @payment = current_user.payments.find_by(gc_id: params[:id])
    if !@payment.nil?
      response = {
        currency: currency_symbol(@payment.currency),
        payment_max_refund: @payment.max_refundable_amount,
      }
    end
    respond_to do |format|
      format.json { render json: response }
    end
  end

  def new
  	@mandates = current_user.mandates.can_take_payment.all
  	@mandate_selected = (@mandates.select { |mandate| mandate.gc_id == params['mandate_id']}).first
  	@mandate_selected = @mandates.last if @mandate_selected.nil?
  	@next_possible_charge_date = @mandate_selected.next_possible_charge_date
  	@payment = PaymentRequest.new(mandate_id: @mandate_selected.gc_id, currency: @mandate_selected.currency, charge_date: @next_possible_charge_date)
  end

  def create
    @mandate = current_user.mandates.can_take_payment.find_by(gc_id: params['payment_request']['mandate_id'])
    @mandates = current_user.mandates.can_take_payment.all
    if @mandate.nil?
      @mandate_selected = (@mandates.select { |mandate| mandate.gc_id == params['mandate_id']}).first
      @mandate_selected = @mandates.last if @mandate_selected.nil?
    else
      @mandate_selected = @mandate
    end
    @next_possible_charge_date = @mandate_selected.next_possible_charge_date
  	@payment = PaymentRequest.new(payment_request_params)

  	if @mandate.nil?
  		flash.now[:alert] = I18n.t('errors.form.payments.select_valid_mandate')
  		render 'new'
  	else
      if !@payment.valid?
        flash.now[:alert] = I18n.t('errors.form.please_correct_form')
        render 'new'
      else
        client = GocardlessPro.new(current_user)
        result = client.create_payment(@payment.params_for_gocardless)
        if result[:success]
          current_user.revenues.create!(
            category: 'payment',
            reference: result[:payment_id],
            amount: @payment.app_fee,
            currency: @payment.currency
          )
          flash.now[:notice] = I18n.t('payments.new.success_message', charge_date: result[:charge_date].to_date.strftime('%d/%m/%Y'))
          @payment = PaymentRequest.new(mandate_id: @mandate_selected.gc_id, currency: @mandate_selected.currency, charge_date: @next_possible_charge_date)
          render 'new'
        else
          result[:errors].each do |error|
            @payment.errors.add(error['field'], error['message'])
          end
          flash.now[:alert] = 'GoCardless: ' + result[:message]
          render 'new'
        end
      end
    end
  end

  def cancel
    @payment = current_user.payments.find_by(gc_id: params['payment_id'])
    if !@payment.nil?
      @results = @payment.cancel
      @cancelled = @results[:success]
      @alert = 'GoCardless: ' + @results[:message] if !@cancelled
    end
    respond_to do |format|
      format.js
    end
  end

  def retry
    @payment = current_user.payments.find_by(gc_id: params['payment_id'])
    if !@payment.nil?
      @results = @payment.retry
      @retried = @results[:success]
      @alert = 'GoCardless: ' + @results[:message] if !@retried
    end
    respond_to do |format|
      format.js
    end
  end

  private

    def payment_request_params
      params.require(:payment_request).permit(:mandate_id, :amount, :description, :reference, :charge_date)
    end
end
