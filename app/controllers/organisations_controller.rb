class OrganisationsController < ApplicationController
  def sync_status
    response = {
		is_synced: (!current_user.nil? and current_user.recent_update?)
	}
    respond_to do |format|
      format.json { render json: response }
    end
  end
end
