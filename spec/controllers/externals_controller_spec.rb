require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalsController do
  describe "when forwardable" do
    integrate_views

    before(:each) do
      @registrant = Factory.create(:step_3_registrant)
      stub(GeoState).online_registrars { [@registrant.home_state.abbreviation] }
    end

    describe "#show" do
      it "shows the choice page" do
        get :show, :registrant_id => @registrant.to_param
        assert_not_nil assigns[:registrant]
        assert_response :success
        assert_select "h1", /\w+ Registrant/
      end
    end

    describe "#go" do
      it "redirects to Colorado site when user data is valid in Colorado" do
        stub(fake_site = Object.new).transfer { "https://www.sos.state.co.us/Voter/editVoterDetails.do" }
        stub(StateRegistrationSite).new(@registrant) { fake_site }
        get :go, :registrant_id => @registrant.to_param
        assert_response :found
        assert_match %r{www\.sos\.state\.co\.us(?::443)?/Voter/editVoterDetails\.do}, response.headers['Location']
      end

      it "shows failure message when user data is not valid in Colorado" do
        stub(fake_site = Object.new).transfer { nil }
        stub(StateRegistrationSite).new(@registrant) { fake_site }
        get :go, :registrant_id => @registrant.to_param

        assert_response :success
        assert_select "li div", @registrant.state_id_number
      end

      it "shows failure message when request times out" do
        stub(fake_site = Object.new).transfer { raise Timeout::Error, "simulated timeout" }
        stub(StateRegistrationSite).new(@registrant) { fake_site }
        get :go, :registrant_id => @registrant.to_param

        assert_response :success
        assert_select ".text p", /may not be available at this time/
      end
    end
  end

  describe "when not forwardable" do
    before(:each) do
      @registrant = Factory.create(:step_3_registrant)
    end

    describe "#show" do
      it "shows Not Found page when not eligible for external online registration" do
        @registrant[:change_of_name] = true
        @registrant.save(false)
        assert !@registrant.reload.forwardable_to_electronic_registration?
        get :show, :registrant_id => @registrant.to_param
        assert_response :not_found
      end
    end
  end
end
