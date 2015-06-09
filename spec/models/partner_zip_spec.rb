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
  after(:each) do
    if File.exists?("#{Rails.root}/public/TEST")
      FileUtils.remove_entry_secure("#{Rails.root}/public/TEST", true)
    end  
  end
  describe "#new_record?" do
    it "returns true" do
      PartnerZip.new(nil).new_record?.should be_truthy
    end
  end
  describe "#create" do
    it "returns false when the zip is missing" do
      PartnerZip.new(nil).create.should be_falsey
    end
    it "returns false when the CSV file is missing" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'missing_csv.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_falsey
    end
    it "looks in folder when the zip file unzips to a subdirectory" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'ejs_good_partners1.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_truthy    
    end
    it "looks into nested folders when the zip file unzips to a subdirectory" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'ejs_good_partners2.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_truthy      
    end
    it "sets an error wben the parter directory has subfolder" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'partner_2_subs.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_falsey
    end
    it "creates and checks validity of each partner in the CSV" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'invalid_partners.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_falsey
      pz.errors.collect{|a,b| a}.should include("Row 1 is invalid")
      pz.errors.collect{|a,b| a}.should include("Row 2 is invalid")
      pz.errors.collect{|a,b| a}.should include("Row 3 is invalid")
    end
    it "creates partners when all is valid and attaches CSVs and email templates when whitelabeled" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'four_good_partners.zip'))
      pz = PartnerZip.new(@file)
      assert_difference("Partner.count", 4) do
        pz.create.should be_truthy
      end
      
      p = Partner.find_by_username("csv_partner_2")
      EmailTemplate.get(p, "confirmation.en").should == "Custom confirmation email\n\nIn English"
      EmailTemplate.get(p, "confirmation.es").should == "Custom confirmation email\n\nIn Spanish"
      EmailTemplate.get(p, "reminder.en").should == "Custom reminder email\n\nIn English"
      EmailTemplate.get(p, "reminder.es").should == "Custom reminder email\n\nIn Spanish"
      p.should be_whitelabeled
      p.application_css_present?.should be_truthy
      p.registration_css_present?.should be_truthy
      p.registration_instructions_url.should be_blank
      p.is_government_partner.should be_truthy
      p.government_partner_state_id.should == GeoState["MA"].id
      
      p4 = Partner.find_by_username("csv_partner_4")
      p4.registration_instructions_url.should == "http://custom-url.com?l=<LOCALE>&s=<STATE>"
      p4.widget_image.should == "rtv-100x100-v1.gif"
      p4.privacy_url.should == "http://example.com/privacy"
      p4.is_government_partner.should be_truthy
      p4.government_partner_zip_codes.should == ["02113","02110"]
      p4.survey_question_1_ko.should == "KO Question 1"
      p4.survey_question_2_zh_tw.should == "ZH-TW Question 2"
      
    end
    it "works when there's just a partner.css" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'just_partner_css.zip'))
      # cleanup remote files first
      clear_partner_asset_test_buckets
      
      pz = PartnerZip.new(@file)
      assert_difference("Partner.count", 1) do
        pz.create.should be_truthy
      end
      
      p = Partner.find_by_username("csv_partner_3")
      EmailTemplate.get(p, "confirmation.en").should == "Custom confirmation email\n\nIn English"
      EmailTemplate.get(p, "confirmation.es").should == "Custom confirmation email\n\nIn Spanish"
      EmailTemplate.get(p, "reminder.en").should == "Custom reminder email\n\nIn English"
      EmailTemplate.get(p, "reminder.es").should == "Custom reminder email\n\nIn Spanish"
      p.should be_whitelabeled
      p.application_css_present?.should be_falsey
      p.registration_css_present?.should be_falsey
      p.partner_css_present?.should be_truthy      
    end
    it "deletes the tmp directory when done regardless of result" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'four_good_partners.zip'))
      pz = PartnerZip.new(@file)
      pz.create
      Dir.entries(PartnerZip.tmp_root).size.should == 2
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'invalid_partners.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should
      Dir.entries(PartnerZip.tmp_root).size.should == 2      
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'ejs_good_partners2.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should
      Dir.entries(PartnerZip.tmp_root).size.should == 2      
    end
    it "sets tracking snippets and survey questions" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'ejs_good_partners1.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_truthy
      
      p = Partner.find_by_username("ejstest_4")
      p.survey_question_2_zh_tw.should == "abc"
      p.external_tracking_snippet.should == "<some code>code snipped</some code>"
      
    end
  end
  describe "#error_messages" do
    it "displays the error messages from the upload" do
      @file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'invalid_partners.zip'))
      pz = PartnerZip.new(@file)
      pz.create.should be_falsey
      pz.error_messages.should include("Row 1 is invalid")
      pz.error_messages.should include("Row 2 is invalid")
      pz.error_messages.should include("Row 3 is invalid")
    end
  end
  
end