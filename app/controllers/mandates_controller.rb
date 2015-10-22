class MandatesController < ApplicationController
  before_action :logged_in_user

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
end
