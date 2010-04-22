require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WidgetImagesController do

  describe "when logged in" do
    before(:each) do
      activate_authlogic
      @partner = Factory.create(:partner, :id => 5)
      PartnerSession.create(@partner)
    end

    describe "show" do
      integrate_views
      it "shows image selection page" do
        get :show
        assert_response :success
        assert_template "show"
        assert_not_nil assigns[:partner]
      end
    end

    describe "update" do
      before(:each) do
        @partner.widget_image_name = "rtv100x100v1"
      end

      it "changes the widget image setting" do
        get :update, :partner => {:widget_image_name => "rtv200x165v1"}
        assert_redirected_to partner_url
        assert_equal "rtv-200x165-v1.gif", assigns[:partner].widget_image
      end
    end
  end

end
