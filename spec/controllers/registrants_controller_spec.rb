require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrantsController do
  describe "#new" do
    it "should show the step 1 input form" do
      get :new
      assert_not_nil assigns[:registrant]
      assert_template "new"
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
  end

  describe "#create" do
    it "should create a new registrant and complete step 1" do
      post :create, :registrant => Factory.attributes_for(:step_1_registrant)
      assert_not_nil assigns[:registrant]
      assert_redirected_to registrant_step_2_path(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      post :create, :registrant => Factory.attributes_for(:step_1_registrant, :home_zip_code => "")
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].new_record?
      assert_template "new"
    end
  end
end
