class PaymentsController < ApplicationController
  before_action :logged_in_user

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

  private

    def payment_request_params
      params.require(:payment_request).permit(:mandate_id, :amount, :description, :reference, :charge_date)
    end
end
