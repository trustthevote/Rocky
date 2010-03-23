require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IneligiblesController do
  integrate_views

  describe "when 18 or over" do
    it "shows not-a-citizen message" do
      @registrant = Factory.create(:step_1_registrant, :us_citizen => false)
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_select "p.reason", /citizen/
    end

    it "shows state-not-participating message" do
      @registrant = Factory.create(:step_1_registrant, :home_zip_code => "58111")
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_select "p.reason", /does not register voters/
    end
  end

  describe "when under 18" do
    it "don't show under-18 page if ineligble in other ways" do
      @registrant = Factory.create(:step_1_registrant, :us_citizen => false, :date_of_birth => 16.years.ago.to_date.strftime("%m/%d/%Y"))
      get :show, :registrant_id => @registrant.to_param
      assert_response :success
      assert_template "show"
    end

    it "shows state localized sub_18 message" do
      @registrant = Factory.create(:step_1_registrant, :date_of_birth => 16.years.ago.to_date.strftime("%m/%d/%Y"))
      assert @registrant.ineligible_age?
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].remind_when_18
      assert assigns[:registrant].opt_in_email
      assert_response :success
      assert_template "under_18"
      assert_match Regexp.new(@registrant.localization.sub_18), response.body
    end
  end
end
