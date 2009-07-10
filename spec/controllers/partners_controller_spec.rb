require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PartnersController do

  describe "widget loader" do
    integrate_views
    
    it "generates bootstrap javascript targeted to server host" do
      stub(request).protocol { "http://" }
      stub(request).host_with_port { "example.com:3000" }
      get :widget_loader, :id => "1", :format => "js"
      assert_response :success
      assert_template "widget_loader.js.erb"
      assert_match %r{createElement}, response.body
      assert_match %r{http://example.com:3000}, response.body
    end
  end

end
