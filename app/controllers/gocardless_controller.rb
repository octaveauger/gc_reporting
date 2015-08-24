class GocardlessController < ApplicationController
  def index
  	redirect_to gocardless_sync_path
  end

  def sync
  	client = GocardlessPro.new(current_user)
  	client.sync_data
  	redirect_to reporting_path
  end
end
