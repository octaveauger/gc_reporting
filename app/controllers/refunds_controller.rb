class RefundsController < ApplicationController
  before_action :logged_in_user
  layout 'backend'

  def new
  	@payments = current_user.payments.can_be_refunded.all
  	@payment_selected = (@payments.select { |payment| payment.gc_id == params['payment_id']}).first
  	@payment_selected = @payments.last if @payment_selected.nil?
  	@refund = RefundRequest.new(payment_id: @payment_selected.gc_id, currency: @payment_selected.currency)
  end

  def create
  	@payment = current_user.payments.can_be_refunded.find_by(gc_id: params['refund_request']['payment_id'])
  	@payments = current_user.payments.can_be_refunded.all
    if @payment.nil?
      @payment_selected = (@payments.select { |payment| payment.gc_id == params['payment_id']}).first
      @payment_selected = @payments.last if @payment_selected.nil?
    else
      @payment_selected = @payment
    end
  	@refund = RefundRequest.new(refund_request_params)

  	if @payment.nil?
  		flash.now[:alert] = I18n.t('errors.form.refund.select_valid_mandate')
  		render 'new'
  	else
      if !@refund.valid?
        flash.now[:alert] = I18n.t('errors.form.please_correct_form')
        render 'new'
      else
        client = GocardlessPro.new(current_user)
        result = client.create_refund(@refund.params_for_gocardless)
        if result[:success]
          redirect_to payments_path, notice: I18n.t('refunds.new.success_message')
        else
          result[:errors].each do |error|
            @refund.errors.add(error['field'], error['message']) if !error['field'].nil? and @refund.respond_to?(error['field'].to_sym)
          end
          flash.now[:alert] = 'GoCardless: ' + result[:message]
          render 'new'
        end
      end
    end
  end

  private

    def refund_request_params
      params.require(:refund_request).permit(:payment_id, :amount, :reference)
    end
end
