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
      @partner = Factory.create(:partner, :id => 5)
      PartnerSession.create(@partner)
    end

    describe "dashboard" do
      integrate_views

      it "shows widget html" do
        stub(request).host { "example.com" }
        get :show
        assert_response :success
        assert_select 'textarea[readonly]', 1
        html = HTML::Node.parse(nil, 0, 0, assigns(:link_html))
        assert_select html, "a[href=https://example.com/registrants/new?partner=5][class=floatbox][data-fb-options='width:604 height:max scrolling:no']"
        html = HTML::Node.parse(nil, 0, 0, assigns(:link_html).split("\n").last)
        assert_select html, "script[type=text/javascript][src=https://example.com/partner/5/widget_loader.js]"
      end
    end

    describe "statistics" do
      it "shows registration statistics" do
        get :statistics
        assert_response :success
        assert_not_nil assigns[:stats_by_state]
        assert_not_nil assigns[:stats_by_completion_date]
        assert_not_nil assigns[:stats_by_race]
        assert_not_nil assigns[:stats_by_gender]
        assert_not_nil assigns[:stats_by_age]
        assert_not_nil assigns[:stats_by_party]
      end
    end

    describe "profile" do
      integrate_views

      it "shows profile edit form" do
        get :edit
        assert_response :success
        assert_equal @partner, assigns[:partner]
        assert_select "form[action=/partner]"
      end

      it "shows dashboard after updating" do
        put :update, :partner => {:name => "Friends of the Moose"}
        assert_redirected_to partner_url
      end

      it "update requires valid input" do
        put :update, :partner => {:email => "bogus!!!!!"}
        assert_response :success
        assert_template "edit"
      end
    end

    describe "download registration data" do
      it "triggers download" do
        get :registrations, :format => 'csv'
        assert_response :success
        assert_equal "text/csv", response.headers["Content-Type"]
      end
    end
  end
end
