require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrantsController do
  describe "landing" do
    it "redirects to /new" do
      get :landing
      assert_redirected_to new_registrant_url(:protocol => "https")
    end

    it "keeps partner, locale and source params when redirecting" do
      get :landing, :partner => "2"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2")
      get :landing, :locale => "es"
      assert_redirected_to new_registrant_url(:protocol => "https", :locale => "es")
      get :landing, :source => "email"
      assert_redirected_to new_registrant_url(:protocol => "https", :source => "email")
      get :landing, :partner => "2", :locale => "es"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es")
      get :landing, :partner => "2", :locale => "es", :source => "email"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es", :source => "email")
    end
  end

  describe "#new" do
    it "should show the step 1 input form" do
      get :new
      assert_not_nil assigns[:registrant]
      assert_template "show"
    end

    it "should start with partner id, locale and tracking source" do
      get :new, :locale => 'es', :partner => '2', :source => 'email'
      reg = assigns[:registrant]
      assert_equal 'es', reg.locale
      assert_equal 2, reg.partner_id
      assert_equal 'email', reg.tracking_source
    end

    it "should default partner id to RTV" do
      get :new
      reg = assigns[:registrant]
      assert_equal Partner.default_id, reg.partner_id
    end

    it "should default locale to English" do
      get :new
      reg = assigns[:registrant]
      assert_equal 'en', reg.locale
    end

    describe "keep initial params in hidden fields" do
      integrate_views

      it "should keep partner, locale and tracking source" do
        get :new, :locale => 'es', :partner => '2', :source => 'email'
        assert_equal '2', assigns[:partner_id].to_s
        assert_equal 'es', assigns[:locale]
        assert_equal 'email', assigns[:source]
        assert_select "input[name=partner][value=2]"
        assert_select "input[name=locale][value=es]"
        assert_select "input[name=source][value=email]"
      end
    end

    describe "partner logo" do
      integrate_views

      it "should not show partner banner or logo for primary partner" do
        get :new, :partner => Partner.default_id.to_s
        assert_select "#header.partner", 0
        assert_select "#partner-logo", 0
      end

      it "should show partner banner and logo for non-primary partner" do
        logo = "https://example.com/logo.jpg"
        partner = Factory.create(:partner, :logo_image_url => logo)
        get :new, :partner => partner.to_param
        assert_select "#header.partner"
        assert_select "#partner-logo img[src=#{logo}]"
      end
    end
  end

  describe "#create" do
    integrate_views

    before(:each) do
      @partner = Factory.create(:partner)
      @reg_attributes = Factory.attributes_for(:step_1_registrant)
    end

    it "should create a new registrant and complete step 1" do
      post :create, :registrant => @reg_attributes
      assert_not_nil assigns[:registrant]
      assert_redirected_to registrant_step_2_url(assigns[:registrant])
    end

    it "should set partner_id, locale and tracking_source" do
      @reg_attributes.delete(:locale)
      post :create, :registrant => @reg_attributes, :partner => "2", :locale => "es", :source => "email"
      assert_equal 2, assigns[:registrant].partner_id
      assert_equal "es", assigns[:registrant].locale
      assert_equal "email", assigns[:registrant].tracking_source
    end

    it "should reject invalid input and show form again" do
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => "")
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].new_record?, assigns[:registrant].inspect
      assert_template "show"
    end

    it "should keep partner and locale for next attempt" do
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => ""), :partner => "2", :locale => "es", :source => "email"
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].new_record?, assigns[:registrant].inspect
      assert_template "show"
      assert_select "input[name=partner][value=2]"
      assert_select "input[name=locale][value=es]"
      assert_select "input[name=source][value=email]"
    end

    it "should reject ineligible registrants" do
      north_dakota_zip = "58001"
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => north_dakota_zip)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].ineligible?
      assert assigns[:registrant].ineligible_non_participating_state?
      assert assigns[:registrant].rejected?
      assert_redirected_to registrant_ineligible_url(assigns[:registrant])
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_4_registrant)
    end

    it "should update registrant and complete step 1" do
      put :update, :id => @registrant.to_param, :registrant => {:email_address => "new@example.com"}
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_1?
      assert_redirected_to registrant_step_2_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :id => @registrant.to_param, :registrant => {:email_address => nil}
      assert assigns[:registrant].step_1?
      assert assigns[:registrant].reload.step_4?
      assert_template "show"
    end
    
    it "should reject ineligible registrants" do
      north_dakota_zip = "58001"
      put :update, :id => @registrant.to_param, :registrant => {:home_zip_code => north_dakota_zip}
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].ineligible?
      assert assigns[:registrant].ineligible_non_participating_state?
      assert assigns[:registrant].rejected?
      assert_redirected_to registrant_ineligible_url(assigns[:registrant])
    end
  end

  describe "completed registration" do
    it "should not be visible" do
      reg = Factory.create(:completed_registrant)
      assert_raise ActiveRecord::RecordNotFound do
        get :show, :id => reg.to_param
      end
    end
  end
  
  describe "abandoned registration" do
    integrate_views

    it "should show a timeout page" do
      reg = Factory.create(:step_1_registrant, :abandoned => true, :locale => "es")
      get :show, :id => reg.to_param
      assert_redirected_to registrants_timeout_url(:partner => reg.partner.id, :locale => reg.locale)
    end
  end
end
