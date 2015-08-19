require 'spec_helper'

describe ReportingController do

  describe "GET 'export_customers'" do
    it "returns http success" do
      get 'export_customers'
      response.should be_success
    end
  end

end
