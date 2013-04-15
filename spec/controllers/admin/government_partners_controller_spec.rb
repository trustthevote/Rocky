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
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GovernmentPartnersController do

  describe 'GET #index' do
    it 'should render the index' do
      get :index
      assigns(:partners).should == Partner.government
      response.should render_template :index
    end
  end
  describe "GET #show" do
    it 'should render the show template' do
      partner = FactoryGirl.create(:partner)
      get :show, :id => partner.id
      assigns(:partner).should == partner
      response.should render_template :show
    end      
  end
  describe "GET #new" do
    it 'should render the new page' do
      get :new
      assigns(:partner).should be_a(Partner)
      assigns(:partner).should be_new_record
      response.should render_template :new
    end
  end
  describe "POST #create" do
    context 'valid data' do
      before(:each) do
        @partner = FactoryGirl.create(:partner)
        stub(@partner).save { true }
        stub(Partner).new.with({"name"=>"new_name", "is_government_partner"=>true})  { @partner }
      end
      it "redirects to the partner page" do
        post :create, :partner => { :name => 'new_name' }
        response.should redirect_to admin_government_partners_path
      end
      it "sets is_government_partner to true" do
        post :create, :partner => { :name => 'new_name' }
        Partner.should have_received(:new).with({"name"=>"new_name", "is_government_partner"=>true})
      end
      it "generates username and password" do
        stub(@partner).generate_username
        stub(@partner).generate_random_password
        post :create, :partner => { :name => 'new_name' }
      end
    end
    context "invalid data" do
      before(:each) do
        @partner = FactoryGirl.create(:partner)
        stub(@partner).save { false }
        stub(Partner).new.with({"name"=>"new_name", "is_government_partner"=>true})  { @partner }
        post :create, :partner => { :name => 'new_name' }
      end
      
      it { should render_template(:new) }
      it "assigns to partner" do
        assigns(:partner).should == @partner
      end
    end
    
  end

  describe 'GET #edit' do
    it 'should display edit form' do
      partner = FactoryGirl.create(:partner)
      get :edit, :id => partner.id
      assigns(:partner).should == partner
      response.should render_template :edit
    end
  end
  
  describe 'PUT #update' do
    before(:each) do
      @partner = FactoryGirl.create(:partner)
    end
    context 'valid data' do
      before  { put :update, :id => @partner, :partner => { :name => 'new_name' } }
      it      { should redirect_to admin_government_partner_path(@partner) }
      specify { @partner.reload.name.should == 'new_name' }
    end

    context 'template updates' do
      before  { put :update, :id => @partner, :template => { 'confirmation.en' => 'body' } }
      specify { EmailTemplate.get(@partner, 'confirmation.en').should == 'body' }
    end

    context 'css updates' do
      before  { @sample_css = fixture_file_upload('/files/sample.css') }
      before  { @paf = PartnerAssetsFolder.new(nil) }
      before  { mock(PartnerAssetsFolder).new(@partner) { @paf } }
      before  { mock(@paf).update_css('application', @sample_css) }
      specify { put :update, :id => @partner, :css_files => { 'application' => @sample_css } }
    end

    context 'invalid data' do
      before  { put :update, :id => @partner, :partner => { :name => '' } }
      it      { should render_template :edit }
    end
  end

end