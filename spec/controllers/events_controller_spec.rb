require 'spec_helper'

describe EventsController do

  describe "GET 'payouts'" do
    it "returns http success" do
      get 'payouts'
      response.should be_success
    end
  end

end
