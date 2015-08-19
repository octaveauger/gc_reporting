class ReportingController < ApplicationController
  def export_customers
  	client = GocardlessPro.new(current_user)
  	client.update_customers
  end
end
