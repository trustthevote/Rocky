require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IneligiblesController do
  integrate_views

  before(:each) do
    @registrant = Factory.create(:step_1_registrant)
  end

  it "show ineligible page" do
    get :show, :registrant_id => @registrant.to_param
    assert_not_nil assigns[:registrant]
    assert_response :success
  end
end
