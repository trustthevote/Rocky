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

describe Partner do

  describe "creation" do
    it "sets an API key on creation" do
      p = Factory(:partner, :api_key=>'')
      p.api_key.should_not be_blank
    end
  end

  describe "#primary?" do
    it "is false for non-primary partner" do
      assert !Factory.build(:partner).primary?
    end
  end
  
  describe "#generate_api_key!" do
    it "should change the api key" do
      p = Factory(:partner)
      p.api_key.should_not be_blank
      old_key = p.api_key
      p.generate_api_key!
      p.reload
      p.api_key.should_not == old_key
    end
  end
  
  describe "#valid_api_key?(key)" do
    it "returns false when blank or not matching" do
      partner = Factory.build(:partner, :api_key=>"")
      partner.valid_api_key?("").should be_false
      partner.api_key="abc"
      partner.valid_api_key?("bca").should be_false
    end
    it "return true when matching" do
      partner = Factory.build(:partner, :api_key=>"abcdef")
      partner.valid_api_key?("abcdef").should be_true
    end
  end

  describe "widget image" do
    it "is set to default value if none set explicitly" do
      partner = Factory.build(:partner, :widget_image => nil)
      assert partner.valid?
      assert_equal Partner::DEFAULT_WIDGET_IMAGE_NAME, partner.widget_image_name
      partner.widget_image_name = "rtv100x100v1"
      assert partner.valid?
      assert_equal "rtv100x100v1", partner.widget_image_name
    end

    it "gets name of widget image" do
      partner = Factory.build(:partner, :widget_image => "rtv-100x100-v1.gif")
      assert_equal "rtv100x100v1", partner.widget_image_name
    end

    it "sets widget_image by name" do
      partner = Factory.build(:partner, :widget_image => nil)
      partner.widget_image_name = "rtv100x100v1"
      assert_equal "rtv-100x100-v1.gif", partner.widget_image
    end
  end

  describe "logo image" do
    it "has an attached logo" do
      partner = Factory.build(:partner)
      assert partner.respond_to?(:logo)
      assert_equal Paperclip::Attachment, partner.logo.class
    end

    it "has an error when the logo is not an image type" do
      File.open(File.join(fixture_path, "files/crazy.txt"), "r") do |crazy|
        partner = Factory.create(:partner)
        partner.update_attributes(:logo => crazy)
        assert !partner.valid?
        assert_match /must be a JPG, GIF, or PNG/, partner.errors.on(:logo)
      end
    end
  end

  describe "custom_logo?" do
    after(:each) do
      FileUtils.rm_rf(Rails.root.join("tmp/system/logos"))
    end

    it "is always false for primary partner" do
      partner = Partner.find(Partner::DEFAULT_ID)
      assert !partner.custom_logo?
      File.open(File.join(fixture_path, "files/partner_logo.jpg"), "r") do |logo|
        partner.update_attributes(:logo => logo)
        assert !partner.custom_logo?
      end
    end

    it "is true for partners with logos" do
      partner = Factory.build(:partner)
      File.open(File.join(fixture_path, "files/partner_logo.jpg"), "r") do |logo|
        partner.update_attributes(:logo => logo)
        assert partner.custom_logo?
      end
    end

    it "is false for partners without logos" do
      partner = Factory.build(:partner)
      assert !partner.custom_logo?
    end
  end

  context "whitelabeling" do
    describe "Class Methods" do
      describe "#add_whitelabel(partner_id, app_css, reg_css)" do
        before(:each) do
          @partner = Factory(:partner)
          stub(File).expand_path("app.css").returns("app.css")
          stub(File).expand_path("reg.css").returns("reg.css")
          stub(File).expand_path("part.css").returns("part.css")

          stub(Partner).find.returns(@partner)
          stub(File).exists?("app.css").returns(true)
          stub(File).exists?("reg.css").returns(true)
          stub(File).exists?("part.css").returns(true)
          stub(@partner).any_css_present?.returns(false)
          stub(@partner).application_css_present?.returns(true)
          stub(@partner).registration_css_present?.returns(true)
          stub(@partner).partner_css_present?.returns(true)

          stub(File).directory?(@partner.assets_path).returns(true)
          stub(FileUtils).cp("app.css", @partner.absolute_application_css_path).returns(true)
          stub(FileUtils).cp("reg.css", @partner.absolute_registration_css_path).returns(true)
          stub(FileUtils).cp("part.css", @partner.absolute_partner_css_path).returns(true)
        end
        it "finds the partner by id" do
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          Partner.should have_received(:find).with("123")
        end
        it "raises an error message if the partner is the primary one" do
          stub(@partner).primary?.returns(true)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("You can't whitelabel the primary partner.")
        end
        it "raises an error message if the partner is not found" do
          stub(Partner).find.returns(nil)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("Partner with id '123' was not found.")
        end
        it "raises an error message with what to do if the partner is already whitelabeled" do
          stub(@partner).whitelabeled.returns(true)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("Partner '123' is already whitelabeled. Try running 'rake partner:upload_assets 123 app.css reg.css'")
        end
        it "raises an error message with what to do if the partner already has assets" do
          stub(@partner).any_css_present?.returns(true)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("Partner '123' has assets. Try running 'rake partner:enable_whitelabel 123'")
        end
        # it "raises an error if the two css files aren't found" do
        #   stub(File).exists?("app.css").returns(false)
        #   stub(File).exists?("reg.css").returns(false)
        #   expect {
        #     Partner.add_whitelabel("123", "app.css", "reg.css")
        #   }.to raise_error("File 'app.css' not found")
        # 
        #   stub(File).exists?("app.css").returns(true)
        #   expect {
        #     Partner.add_whitelabel("123", "app.css", "reg.css")
        #   }.to raise_error("File 'reg.css' not found")
        # end
        it "sets the partner as whitelabeled if not already" do
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          Partner.find(@partner.id).should be_whitelabeled
        end

        it "creates the partner path if not already there" do
          stub(File).directory?(@partner.assets_path).returns(false)
          stub(Dir).mkdir(@partner.assets_path).returns(true)
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          Dir.should have_received(:mkdir).with(@partner.assets_path)
        end
        it "copies the CSS to the partner path (with the correct names) from the filesystem" do
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          FileUtils.should have_received(:cp).with("app.css", @partner.absolute_application_css_path)
          FileUtils.should have_received(:cp).with("reg.css", @partner.absolute_registration_css_path)
          FileUtils.should have_received(:cp).with("part.css", @partner.absolute_partner_css_path)
        end
        it "copies the CSS files to the partner path (with the correct names) from URLs" do
          pending "Don't need URL designation of assets yet"
        end
        it "does not set the partner as whitelabeled if the path functions fail" do
          stub(FileUtils).cp("app.css", @partner.absolute_application_css_path)
          stub(@partner).application_css_present?.returns(false)
          begin
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          rescue
          end
          Partner.find(@partner.id).should_not be_whitelabeled
        end
        it "outputs the partner path on success" do
          output = Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          output.should == "Partner '123' has been whitelabeled. Place all asset files in\n#{@partner.assets_path}"
        end
      end
    end


    describe "#assets_url" do
      it "returns the url for the partner directory" do
        partner = Factory(:partner)
        partner.assets_url.should == "/partners/#{partner.id}"
      end
    end
    describe "#assets_path" do
      it "returns the absolute path to the partner directory" do
        partner = Factory(:partner)
        partner.assets_path.should == "#{RAILS_ROOT}/public/TEST/partners/#{partner.id}"
      end
    end
    describe "#absolute_application_css_path" do
      it "returns the path RAILS_ROOT/public/TEST/partners/PARTNER_ID/style.css" do
        partner = Factory(:partner)
        partner.absolute_application_css_path.should == "#{RAILS_ROOT}/public/TEST/partners/#{partner.id}/application.css"
      end
    end
    describe "#absolute_registration_css_path" do
      it "returns the path RAILS_ROOT/public/TEST/partners/PARTNER_ID/style.css" do
        partner = Factory(:partner)
        partner.absolute_registration_css_path.should == "#{RAILS_ROOT}/public/TEST/partners/#{partner.id}/registration.css"
      end
    end
    describe "#absolute_partner_css_path" do
      it "returns the path RAILS_ROOT/public/TEST/partners/PARTNER_ID/partner.css" do
        partner = Factory(:partner)
        partner.absolute_partner_css_path.should == "#{RAILS_ROOT}/public/TEST/partners/#{partner.id}/partner.css"
      end
    end
    describe "#css_present?" do
      it "returns true if the both custom css files are present" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        partner.css_present?.should be_true
        File.should have_received(:exists?).with(partner.absolute_application_css_path)
        File.should have_received(:exists?).with(partner.absolute_registration_css_path)
      end
      it "returns false if the custom application css file is not present" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        partner.css_present?.should be_false
      end
      it "returns false if the custom registration css file is not present" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        partner.css_present?.should be_false
      end
      it "returns false if the both custom css files are not present" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        partner.css_present?.should be_false
      end
    end

    describe "#any_css_present?" do
      it "returns true if the either custom css files is present" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        stub(File).exists?(partner.absolute_partner_css_path).returns(false)
        partner.any_css_present?.should be_true

        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        stub(File).exists?(partner.absolute_partner_css_path).returns(false)
        partner.any_css_present?.should be_true

        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        stub(File).exists?(partner.absolute_partner_css_path).returns(true)
        partner.any_css_present?.should be_true

        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        stub(File).exists?(partner.absolute_partner_css_path).returns(true)
        partner.any_css_present?.should be_true
      end
      it "returns false if both css files are missing" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        stub(File).exists?(partner.absolute_partner_css_path).returns(false)
        partner.any_css_present?.should be_false
      end
    end

    describe "#application_css_present?" do
      it "returns true when the file exists" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        partner.application_css_present?.should be_true
      end
      it "returns false when the file is missing" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        partner.application_css_present?.should be_false
      end
    end
    describe "#registration_css_present?" do
      it "returns true when the file exists" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        partner.registration_css_present?.should be_true
      end
      it "returns false when the file is missing" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        partner.registration_css_present?.should be_false
      end
    end
    describe "#partner_css_present?" do
      it "returns true when the file exists" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_partner_css_path).returns(true)
        partner.partner_css_present?.should be_true
      end
      it "returns false when the file is missing" do
        partner = Factory.build(:partner)
        stub(File).exists?(partner.absolute_partner_css_path).returns(false)
        partner.partner_css_present?.should be_false
      end
    end

    describe "#application_css_url" do
      it "is returns the URL for the custom application css" do
        partner = Factory.build(:partner)
        partner.application_css_url.should == "/partners/#{partner.id}/application.css"
      end
    end
    describe "#registration_css_url" do
      it "is returns the URL for the custom registration css" do
        partner = Factory.build(:partner)
        partner.registration_css_url.should == "/partners/#{partner.id}/registration.css"
      end
    end
    describe "#partner_css_url" do
      it "is returns the URL for the custom partner css" do
        partner = Factory.build(:partner)
        partner.partner_css_url.should == "/partners/#{partner.id}/partner.css"
      end
    end
    
  
    
  end

  describe "default opt-in sets" do
    it "should be true for RTV and false for partners" do
      partner = Partner.new
      partner.rtv_email_opt_in.should be_true
      partner.partner_email_opt_in.should be_false
      partner.rtv_sms_opt_in.should be_true
      partner.partner_sms_opt_in.should be_false
      partner.ask_for_volunteers.should be_true
      partner.partner_ask_for_volunteers.should be_false
    end
  end

  describe "CSV" do
    it "can generate CSV of all registrants" do
      partner = Factory.create(:partner)
      registrants = []
      3.times { registrants << Factory.create(:maximal_registrant, :partner => partner) }
      registrants << Factory.create(:step_1_registrant, :partner => partner)

      other_partner = Factory.create(:partner)
      registrants << Factory.create(:maximal_registrant, :partner => other_partner)

      csv = FasterCSV.parse(partner.generate_registrants_csv)
      assert_equal 5, csv.length # including header
      assert_equal Registrant::CSV_HEADER, csv[0]
      assert_equal registrants[0].to_csv_array, csv[1]
      assert_equal registrants[1].to_csv_array, csv[2]
      assert_equal registrants[2].to_csv_array, csv[3]
      assert_equal registrants[3].to_csv_array, csv[4]
    end
  end

  describe "registration statistics" do
    describe "by state" do
      it "should tally registrants by state" do
        partner = Factory.create(:partner)
        3.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        3.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        3.times do
          reg = Factory.create(:step_4_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = Factory.create(:step_5_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "94101", :party => "Decline to State")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should only include data for this partner" do
        partner = Factory.create(:partner)
        other_partner = Factory.create(:partner)
        3.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        3.times do
          reg = Factory.create(:maximal_registrant, :partner => other_partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by race" do
      it "should tally registrants by race" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should treat race names in different languages as equivalent" do
        partner = Factory.create(:partner)
        4.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispano", :locale => "es") }
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial", :locale => "es") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 6, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 4, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "doesn't need both English and Spanish results" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial", :locale => "es") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "when the race is blank it is called 'Unknown'" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Unknown", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:step_4_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:step_5_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should only include data for this partner" do
        partner = Factory.create(:partner)
        other_partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        3.times { Factory.create(:maximal_registrant, :partner => other_partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by gender" do
      it "should tally registrants by gender based on name_title" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        stats = partner.registration_stats_gender
        assert_equal 2, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should treat titles in different languages as equivalent" do
        partner = Factory.create(:partner)
        4.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Sr.") }
        3.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Sra.") }
        stats = partner.registration_stats_gender
        assert_equal 2, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 6, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 4, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "doesn't need both English and Spanish results" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Sra.") }
        stats = partner.registration_stats_gender
        assert_equal 2, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { Factory.create(:step_4_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { Factory.create(:step_5_registrant, :partner => partner, :name_title => "Sra.") }
        stats = partner.registration_stats_gender
        assert_equal 2, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should only include data for this partner" do
        partner = Factory.create(:partner)
        other_partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        3.times { Factory.create(:maximal_registrant, :partner => other_partner, :name_title => "Mr.") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        stats = partner.registration_stats_gender
        assert_equal 2, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by registration date" do
      it "should tally registrants by date bucket" do
        partner = Factory.create(:partner)
        8.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        5.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago) }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.weeks.ago) }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.months.ago) }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.years.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal  8, stats[:day_count]
        assert_equal 13, stats[:week_count]
        assert_equal 17, stats[:month_count]
        assert_equal 19, stats[:year_count]
        assert_equal 20, stats[:total_count]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        8.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        8.times { Factory.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        8.times { Factory.create(:step_5_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal  16, stats[:day_count]
      end

      it "should show percent complete" do
        partner = Factory.create(:partner)
        8.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        8.times { Factory.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal 0.5, stats[:percent_complete]
      end

      it "should not include :initial state registrants in calculations" do
        partner = Factory.create(:partner)
        5.times { Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago) }
        5.times { Factory.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago) }
        5.times { Factory.create(:step_1_registrant,  :partner => partner, :created_at => 2.days.ago, :status => :initial) }
        stats = partner.registration_stats_completion_date
        assert_equal   5, stats[:week_count]
        assert_equal 0.5, stats[:percent_complete]
      end

      it "should only include data for this partner" do
        partner = Factory.create(:partner)
        other_partner = Factory.create(:partner)
        Factory.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago)
        Factory.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago)
        Factory.create(:maximal_registrant, :partner => other_partner, :created_at => 2.days.ago)
        stats = partner.registration_stats_completion_date
        assert_equal   1, stats[:week_count]
        assert_equal 0.5, stats[:percent_complete]
      end
    end

    describe "by age" do
      it "should tally registrants count and percentage by age bracket on updated_at date" do
        partner = Factory.create(:partner)
        8.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }
        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
        assert_equal  0.40, stats[:age_under_18][:percentage]
        assert_equal  0.25, stats[:age_18_to_29][:percentage]
        assert_equal  0.20, stats[:age_30_to_39][:percentage]
        assert_equal  0.10, stats[:age_40_to_64][:percentage]
        assert_equal  0.05, stats[:age_65_and_up][:percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        8.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { Factory.create(:step_5_registrant,  :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        8.times { Factory.create(:under_18_finished_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        8.times { Factory.create(:step_1_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { Factory.create(:step_2_registrant, :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { Factory.create(:step_3_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { Factory.create(:step_4_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }

        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
      end

      it "should only include data for this partner" do
        partner = Factory.create(:partner)
        other_partner = Factory.create(:partner)
        8.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { Factory.create(:step_5_registrant,  :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        8.times { Factory.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { Factory.create(:step_5_registrant,  :partner => other_partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { Factory.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { Factory.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { Factory.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
      end
    end

    describe "by party" do
      it "should tally registrants by party" do
        partner = Factory.create(:partner)
        1.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Democratic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Green") }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Republican") }
        5.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Other") }
        8.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Decline to State") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end

      it "counts states that do not require party as None" do
        partner = Factory.create(:partner)
        1.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Democratic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Green") }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Other") }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Decline to State") }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "02134") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end

      it "should only include data for this partner" do
        partner = Factory.create(:partner)
        other_partner = Factory.create(:partner)
        1.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Democratic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Green") }
        4.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Other") }
        8.times { Factory.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Decline to State") }
        4.times { Factory.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { Factory.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Other") }
        8.times { Factory.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Decline to State") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end
    end
  end
end

