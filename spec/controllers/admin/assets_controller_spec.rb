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

describe Admin::AssetsController do

  before { @paf = stub }
  before { @partner = Factory(:partner) }
  before { stub(controller).assets_folder { @paf } }

  describe 'index' do
    before  { mock(@paf).list_assets { [] } }
    before  { get :index, :partner_id => @partner }
    specify { assigns(:assets).should be }
    it      { should render_template :index }
  end

  describe 'destroy' do
    before  { mock(@paf).delete_asset('application.css') }
    before  { delete :destroy, :partner_id => @partner, :id => 0, :name => 'application.css' }
    it      { should redirect_to admin_partner_assets_path(@partner) }
  end

  describe 'create' do
    before  { @file = fixture_file_upload('/files/sample.css') }
    before  { mock(@paf).update_asset('sample.css', @file) }
    before  { post :create, :partner_id => @partner, :asset => { :file => @file } }
    it      { should redirect_to admin_partner_assets_path(@partner) }
  end
end
