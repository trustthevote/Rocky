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

describe RegistrationStep do

  before do
    @rs = RegistrationStep.new
    @partner = Factory(:partner)
    @reg = Factory(:step_5_registrant, :partner => @partner)
  end

  it 'should set partner fields' do
    @rs.send(:find_registrant, nil, { :id => @reg.to_param })
    @rs.instance_variable_get("@partner").should    == @partner
    @rs.instance_variable_get("@partner_id").should == @partner.id
  end

  it 'should set registrant' do
    @rs.send(:find_registrant, nil, { :id => @reg.to_param })
    @rs.instance_variable_get("@registrant").should == @reg
  end
  
  it "should set the registrant's finish_with_state flag to false if it was true" do
    @reg.update_attributes(:finish_with_state=>true)
    @reg.finish_with_state.should be_true
    @rs.send(:find_registrant, nil, { :id => @reg.to_param })
    @reg.reload
    @reg.finish_with_state.should be_false
  end
  
end
