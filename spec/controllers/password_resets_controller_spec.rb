require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordResetsController do
  describe "GET #new" do
    it "should work" do
      get :new
      response.should be_success
      response.should render_template(:new)
    end
  end

  describe "GET #edit" do
    context "with a valid perishable token" do
      attr_reader :partner
      before do
        @partner = Factory.create(:partner)
        mock(Partner).find_using_perishable_token(anything) { partner }
      end
      it "should work" do
        get :edit, :id => partner.perishable_token
        response.should be_success
        response.should render_template(:edit)
      end
    end
    context "with an invalid perishable token" do
      it "display a flash" do
        get :edit, :id => "bogus"
        assert_redirected_to login_url
        flash[:warning].should =~ /We're sorry, but we could not locate your account/i
      end
    end
  end

  describe "POST #create" do
    context "with a valid email" do
      before do
        mock(fake_partner = Object.new).deliver_password_reset_instructions!
        mock(Partner).find_by_login.with(anything) { fake_partner }
      end
      it "sends a notification to the Partner's email to reset password" do
        post :create, :login => "mocked@example.com"
        assert_redirected_to login_url
      end
    end
    context "with an invalid email" do
      it "displays a flash" do
        post :create, :email => ""
        assert flash[:warning] =~ /No account was found/i
        assert_template "new"
      end
    end
  end

  describe "PUT #update" do
    attr_reader :partner
    before do
      @partner = Factory.create(:partner)
      mock(Partner).find_using_perishable_token(anything) { partner }
    end
    it "should work" do
      put :update, :id => partner.perishable_token, :partner => {:password => 'newpassword', :password_confirmation => 'newpassword'}
      assert_redirected_to login_url
      flash[:success].should =~ /Password successfully updated/i
    end
  end
end
