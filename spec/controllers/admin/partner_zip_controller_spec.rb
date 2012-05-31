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

describe Admin::PartnerZipsController do
  describe "create" do
    before(:each) do
      @file = fixture_file_upload('files/four_good_partners.zip')
      @pz = PartnerZip.new(nil)
    end
    context "results" do
      before(:each) do
        post :create, :partner_zip => {:zip_file=>@file}
      end
      it { should redirect_to(admin_partners_path) }      
    end
    it "extracts the zip file to a tmp directory" do
      mock(PartnerZip).new(@file) { @pz }
      post :create, :partner_zip => {:zip_file=>@file}
      PartnerZip.should have_received(:new).with(@file)
    end
    it "creates partners in bulk from the extracted directory" do
      mock(PartnerZip).new(@file) { @pz }
      mock(@pz).create { true }
      post :create, :partner_zip => {:zip_file=>@file}
      @pz.should have_received(:create)
    end
    it "sets a flash message when there are errors" do
      mock(PartnerZip).new(@file) { @pz }
      mock(@pz).create { false }
      mock(@pz).error_messages {"An error message"}
      post :create, :partner_zip => {:zip_file=>@file}
      flash[:warning].should == "An error message"
    end
  end
end