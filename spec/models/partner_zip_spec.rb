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
require File.dirname(__FILE__) + '/../spec_helper'

describe PartnerZip do
  describe "#new_record?" do
    it "returns true" do
      PartnerZip.new(nil).new_record?.should be_true
    end
  end
  describe "#create" do
    it "returns false when the zip is missing" do
      PartnerZip.new(nil).create.should be_false
    end
    it "returns false when the CSV file is missing" do
      @file = File.open(File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', 'missing_csv.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_false
    end
    it "creates and checks validity of each partner in the CSV" do
      @file = File.open(File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', 'invalid_partners.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_false
      pz.errors.collect{|a,b| a}.should include("Row 1 is invalid")
      pz.errors.collect{|a,b| a}.should include("Row 2 is invalid")
      pz.errors.collect{|a,b| a}.should include("Row 3 is invalid")
      pz.errors.collect{|a,b| a}.should include("Row 4 is whitelabeled and missing application.css in /partner_4")
      pz.errors.collect{|a,b| a}.should include("Row 4 is whitelabeled and missing registration.css in /partner_4")
    end
    it "creates partners when all is valid and attaches CSVs when whitelabeled" do
      @file = File.open(File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', 'four_good_partners.zip'))
      pz = PartnerZip.new(@file)
      assert_difference("Partner.count", 4) do
        pz.create.should be_true
      end
    end
  end
  
end