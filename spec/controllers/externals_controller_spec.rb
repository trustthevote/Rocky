require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalsController do
  before(:each) do
    @registrant = Factory.create(:step_3_registrant)
    stub(GeoState).online_registrars { [@registrant.home_state.abbreviation] }
  end

  describe "#show" do
    integrate_views
    it "shows the choice page" do
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_select "h1", /\w+ Registrant/
    end

    it "shows Not Found page when not eligible for external online registration" do
      pending
    end
  end

  describe "#go" do
    it "when user data is valid in Colorado" do
      unless ENV['INTEGRATE_COLORADO']
        stub(fake_site = Object.new).transfer { "https://www.sos.state.co.us/Voter/editVoterDetails.do" }
        stub(StateRegistrationSite).new(@registrant) { fake_site }
      end
      get :go, :registrant_id => @registrant.to_param

      assert_response :found
      assert_match %r{www\.sos\.state\.co\.us(?::443)?/Voter/editVoterDetails\.do}, response.headers['Location']
    end

    it "when user data is not valid in Colorado" do
      unless ENV['INTEGRATE_COLORADO']
        stub(fake_site = Object.new).transfer { nil }
        stub(StateRegistrationSite).new(@registrant) { fake_site }
      end
      get :go, :registrant_id => @registrant.to_param

      assert_response :success
      assert_template "go"
    end
  end
end
