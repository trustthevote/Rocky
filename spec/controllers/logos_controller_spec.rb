require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LogosController do
  integrate_views
  
  before(:each) do
    activate_authlogic
    @partner = Factory.create(:partner, :id => 5)
    PartnerSession.create(@partner)
  end

  it "can upload a logo" do
    get :show
    assert_response :success
    assert_template "show"
    assert_not_nil assigns[:partner]
  end
end
