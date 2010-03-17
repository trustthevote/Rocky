require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TimeoutsController do
  integrate_views

  it "shows timeout page" do
    get :index
    assert_response :success
    assert_template "index"
  end
end
