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
require File.expand_path(File.dirname(__FILE__) + '/../../rails_helper')

describe Admin::PartnersController do


  describe 'for UI-only deploys' do
    it "redirects to the core UI" do
      old_role = ENV['ROCKY_ROLE']
      ENV['ROCKY_ROLE'] = 'UI'
      get :index
      response.should redirect_to("#{RockyConf.api_host_name}/admin")
      ENV['ROCKY_ROLE'] = old_role
      
    end
  end
  

  describe 'index' do
    it 'should render the index' do
      get :index
      assigns(:partners).should == Partner.standard
      response.should render_template :index
    end
  end

  describe 'show' do
    it 'should display partner record' do
      partner = FactoryGirl.create(:partner)
      get :show, :id => partner.id
      assigns(:partner).should == partner
      response.should render_template :show
    end
  end

  describe 'edit' do
    it 'should display edit form' do
      partner = FactoryGirl.create(:partner)
      get :edit, :id => partner.id
      assigns(:partner).should == partner
      response.should render_template :edit
    end
  end

  describe 'update' do
    before  { @partner = FactoryGirl.create(:partner) }

    context 'valid data' do
      before  { put :update, :id => @partner, :partner => { :name => 'new_name' } }
      it      { should redirect_to admin_partner_path(@partner) }
      specify { @partner.reload.name.should == 'new_name' }
    end

    context 'template updates' do
      before  { put :update, :id => @partner, :template => { 'confirmation.en' => 'body' } }
      specify { EmailTemplate.get(@partner, 'confirmation.en').should == 'body' }
    end

    context 'css updates' do
      before  { @sample_css = fixture_files_file_upload('/sample.css') }
      before  { @paf = PartnerAssetsFolder.new(nil) }
      before  { PartnerAssetsFolder.stub(:new).with(@partner) { @paf } }
      before  { @paf.stub(:update_css).with('application', @sample_css) }
      specify { put :update, :id => @partner, :css_files => { 'application' => @sample_css } }
    end

    context 'invalid data' do
      before  { put :update, :id => @partner, :partner => { :name => '' } }
      it      { should render_template :edit }
    end
  end
  
  describe "GET regen_api_key" do
    before(:each) do
      @partner = FactoryGirl.create(:partner)
      @partner.stub(:generate_api_key!) { true }
      Partner.stub(:find).with("1") { @partner }
      get :regen_api_key, :id=>"1"
    end
    it { 
      should redirect_to admin_partner_path(@partner)
    }
  end

end
