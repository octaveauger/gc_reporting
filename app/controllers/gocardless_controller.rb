class GocardlessController < ApplicationController
  def sync
  	client = GocardlessPro.new(current_user)
  	client.sync_data
  	redirect_to reporting_path
  end
end
