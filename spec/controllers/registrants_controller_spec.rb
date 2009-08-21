require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrantsController do
  describe "#new" do
    it "should show the step 1 input form" do
      get :new
      assert_not_nil assigns[:registrant]
      assert_template "show"
    end

    it "should start with partner id and locale" do
      get :new, :locale => 'es', :partner => '2'
      reg = assigns[:registrant]
      assert_equal 'es', reg.locale
      assert_equal 2, reg.partner_id
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

    describe "partner logo" do
      integrate_views

      it "should show powered-by for primary partner" do
        get :new
        assert_select "#powered-by", true
      end

      it "should show powered-by for non-primary partner" do
        partner = Factory.create(:partner)
        get :new, :partner => partner.to_param
        assert_select "#powered-by"
      end

      it "should show partner logo for non-primary partner" do
        logo = "http://example.com/logo.jpg"
        partner = Factory.create(:partner, :logo_image_url => logo)
        get :new, :partner => partner.to_param
        assert_select "#partner-logo img[src=#{logo}]"
      end
    end
  end

  describe "#create" do
    before(:each) do
      @partner = Factory.create(:partner)
      @reg_attributes = Factory.attributes_for(:step_1_registrant, :partner_id => @partner.to_param)
    end
    it "should create a new registrant and complete step 1" do
      post :create, :registrant => @reg_attributes
      assert_not_nil assigns[:registrant]
      assert_redirected_to registrant_step_2_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => "")
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].new_record?, assigns[:registrant].inspect
      assert_template "show"
    end

    it "should reject ineligible registrants" do
      north_dakota_zip = "58001"
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => north_dakota_zip)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].ineligible?
      assert assigns[:registrant].ineligible_non_participating_state?
      assert assigns[:registrant].rejected?
      assert_redirected_to ineligible_registrant_url(assigns[:registrant])
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
      assert_redirected_to ineligible_registrant_url(assigns[:registrant])
    end

  end

  describe "download" do
    before(:each) do
      @registrant = Factory.create(:step_5_registrant)
      `touch #{@registrant.pdf_file_path}`
    end

    it "provides a link to download the PDF" do
      get :download, :id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "download"
    end

    after(:each) do
      `rm #{@registrant.pdf_file_path}`
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
      reg = Factory.create(:step_1_registrant, :abandoned => true)
      get :show, :id => reg.to_param
      assert_redirected_to timeout_registrants_url
    end

    it "shows timeout page" do
      get :timeout
      assert_response :success
    end

  end
end
