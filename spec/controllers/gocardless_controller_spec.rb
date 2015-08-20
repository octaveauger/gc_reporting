require 'spec_helper'

describe GocardlessController do

  describe "GET 'sync'" do
    it "returns http success" do
      get 'sync'
      response.should be_success
    end
  end

end
