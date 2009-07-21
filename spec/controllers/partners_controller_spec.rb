require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PartnersController do

  describe "widget loader" do
    integrate_views

    it "generates bootstrap javascript targeted to server host" do
      stub(request).protocol { "http://" }
      stub(request).host_with_port { "example.com:3000" }
      get :widget_loader, :id => "2", :format => "js"
      assert_response :success
      assert_template "widget_loader.js.erb"
      assert_match %r{createElement}, response.body
      assert_match %r{'http://example.com:3000'}, response.body
      assert_match %r{'/registrants/new\?partner=2'}, response.body
    end
  end

  describe "registering" do
    it "creates a new partner" do
      assert_difference("Partner.count") do
        post :create, :partner => Factory.attributes_for(:partner)
      end
      assert_not_nil assigns[:partner]
    end

    it "requires login, email and password for new partner" do
      assert_no_difference("Partner.count") do
        post :create, :partner => Factory.attributes_for(:partner, :username => nil)
      end
      assert_template "new"
    end
  end

  describe "when not logged in" do
    it "prevents access to authenticated pages" do
      get :show
      assert_redirected_to login_url
    end
  end

  describe "when logged in" do
    before(:each) do
      activate_authlogic
      PartnerSession.create(Factory.build(:partner, :id => 5))
    end

    describe "dashboard" do
      integrate_views

      it "shows widget html" do
        stub(request).protocol { "http://" }
        stub(request).host_with_port { "example.com:3000" }
        get :show
        assert_response :success
        assert_select 'textarea[readonly]', 2
        assert_match %r{http://example.com:3000/registrants/new\?partner=5}, response.body
        assert_match %r{partners/5/widget_loader\.js}, response.body
      end
    end
  end
end
