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
require File.expand_path(File.dirname(__FILE__) + '/../../../rails_helper')

describe Api::V2::PartnersController do

  describe 'show' do
    it 'should catch errors' do
      expect_api_error :message => 'error'
      partner { raise ArgumentError.new('error') }
    end

    it 'should return partner details' do
      expect_api_response :response
      partner { :response }
    end
  end

  describe 'show public' do
    it 'should return only public data' do
      expect_api_response :response
      public_partner { :response }
    end
  end

  describe "#create" do
    it "should return the ID of the created partner" do
      expect_api_response :partner_id => "2342"
      partner = double(Partner)
      partner.stub(:id) { 2342 }
      new_partner { partner }
    end

    it 'should catch invalid fields' do
      expect_api_error :message => "Error message", :field_name => "invalid_field"
      new_partner { raise V2::RegistrationService::ValidationError.new('invalid_field', 'Error message') }
    end
    it 'should report invalid parameter type' do
      expect_api_error :message => "Invalid parameter type", :field_name => "attr"
      new_partner { raise(ActiveRecord::UnknownAttributeError, 'unknown attribute: attr') }
    end

  end


  private

  def partner(&block)
    query = { :partner_id => nil, :partner_api_key => nil }
    V2::PartnerService.stub(:find).with(query, false, &block)
    get :show, :format => 'json'
  end

  def public_partner(&block)
    query = { :partner_id => nil, :partner_api_key => nil }
    V2::PartnerService.stub(:find).with(query, true, &block)
    get :show_public, :format => 'json'
  end

  def new_partner(&block)
    data = {}
    V2::PartnerService.stub(:create_record).with(data, &block)
    post :create, :format => 'json', :partner => data
  end


end
