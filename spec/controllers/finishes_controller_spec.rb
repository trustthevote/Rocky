require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FinishesController do
  integrate_views

  before(:each) do
    @registrant = Factory.create(:step_5_registrant)
  end

  it "shows share links and tell-a-friend email form" do
    get :show, :registrant_id => @registrant.to_param
    assert_not_nil assigns[:registrant]
    assert_response :success
    assert_template "finish"
    assert_select "div.share div", 3
    assert_select "form div.button a.button_sendemail_en"
  end
end
