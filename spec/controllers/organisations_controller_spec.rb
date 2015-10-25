require 'spec_helper'

describe OrganisationsController do

  describe "GET 'sync_status'" do
    it "returns http success" do
      get 'sync_status'
      response.should be_success
    end
  end

end
