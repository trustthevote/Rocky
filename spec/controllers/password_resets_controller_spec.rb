#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

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
        @partner = FactoryGirl.create(:partner)
        Partner.stub(:find_using_perishable_token).with(anything) { partner }
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
        fake_partner = spy(Partner)
        fake_partner.stub(:deliver_password_reset_instructions!)
        Partner.stub(:find_by_login).with(anything) { fake_partner }
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
    render_views

    attr_reader :partner
    before do
      @partner = FactoryGirl.create(:partner)
      Partner.stub(:find_using_perishable_token).with(anything) { partner }
    end

    it "should work" do
      put :update, :id => partner.perishable_token, :partner => {:password => 'newpassword', :password_confirmation => 'newpassword'}
      assert_redirected_to login_url
      flash[:success].should =~ /Password successfully updated/i
    end

    it "shows an error when password is blank" do
      put :update, :id => partner.perishable_token, :partner => {:password => '', :password_confirmation => ''}
      assert_response :success
      assert_template "edit"
      assert_select "span.error", "Password cannot be blank"
    end
  end
end
