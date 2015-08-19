require 'spec_helper'

describe ConnectController do

  describe "GET 'authorise'" do
    it "returns http success" do
      get 'authorise'
      response.should be_success
    end
  end

  describe "GET 'callback'" do
    it "returns http success" do
      get 'callback'
      response.should be_success
    end
  end

  describe "GET 'logout'" do
    it "returns http success" do
      get 'logout'
      response.should be_success
    end
  end

end
