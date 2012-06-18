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
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrantsController do
  describe "widget loader" do
    integrate_views

    it "generates bootstrap javascript targeted to server host" do
      stub(request).protocol { "http://" }
      stub(request).host_with_port { "example.com:3000" }
      get :widget_loader, :format => "js"
      assert_response :success
      assert_template "widget_loader.js.erb"
      assert_match %r{createElement}, response.body
    end
  end

  describe "landing" do
    it "redirects to /new, and leaves out partner when none given" do
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

    it "assumes default partner when partner given doesn't exist" do
      non_existent_partner_id = 43243243
      assert Partner.find_by_id(non_existent_partner_id).nil?
      get :landing, :partner => non_existent_partner_id.to_s
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => Partner::DEFAULT_ID)
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
      assert_equal Partner::DEFAULT_ID, reg.partner_id
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
        get :new, :partner => Partner::DEFAULT_ID.to_s
        assert_select "#header.partner", 0
        assert_select "#partner-logo", 0
      end

      it "should show partner banner and logo for non-primary partner with custom logo" do
        partner = Factory.create(:partner)
        File.open(File.join(fixture_path, "files/partner_logo.jpg"), "r") do |logo|
          partner.update_attributes(:logo => logo)
          assert partner.custom_logo?
        end
        get :new, :partner => partner.to_param
        assert_response :success
        assert_select "#header.partner"
        assert_select "#partner-logo img[src=#{partner.logo.url(:header).split('?').first}]"
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
      @reg_attributes.delete(:partner_id)
      post :create, :registrant => @reg_attributes, :partner => @partner.id, :locale => "es", :source => "email"
      assert_equal @partner.id, assigns[:registrant].partner_id
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

  describe "registration step" do
    describe "missing registration" do
      it "should show 404" do
        assert_nil Registrant.find_by_uid("987654321")
        assert_raise ActiveRecord::RecordNotFound do
          get :show, :id => "987654321"
        end
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

    describe "under-18 finished registration" do
      it "should not be visible" do
        reg = Factory.create(:under_18_finished_registrant)
        assert_raise ActiveRecord::RecordNotFound do
          get :show, :id => reg.to_param
        end
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
