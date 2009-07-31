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
      partner = Factory.create(:partner)
      post :create, :registrant => Factory.attributes_for(:step_1_registrant, :partner_id => partner.to_param)
      assert_not_nil assigns[:registrant]
      assert_redirected_to registrant_step_2_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      post :create, :registrant => Factory.attributes_for(:step_1_registrant, :home_zip_code => "")
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].new_record?
      assert_template "new"
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
      assert assigns[:registrant].step_4?
      assert_template "new"
    end
  end

  describe "download" do
    it "provides a link to download the PDF" do
      @registrant = Factory.create(:maximal_registrant)
      get :download, :id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "download"
    end
  end

  describe "PDF" do
    before(:each) do
      @registrant = Factory.create(:maximal_registrant)
      `touch #{@registrant.pdf_path}`
    end

    it "downloads the PDF to the browser" do
      get :pdf, :id => @registrant.to_param
      assert_equal 'application/pdf', response.content_type
    end

    after(:each) do
      `rm #{@registrant.pdf_path}`
    end
  end

end
