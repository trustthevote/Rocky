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
      p = FactoryGirl.create(:partner, :api_key=>'')
      p.api_key.should_not be_blank
    end
  end

  describe "#primary?" do
    it "is false for non-primary partner" do
      assert !FactoryGirl.build(:partner).primary?
    end
  end
  
  describe "#generate_api_key!" do
    it "should change the api key" do
      p = FactoryGirl.create(:partner)
      p.api_key.should_not be_blank
      old_key = p.api_key
      p.generate_api_key!
      p.reload
      p.api_key.should_not == old_key
    end
  end
  
  describe "#generate_random_password" do
    it "sets the password and password confirmation" do
      p = FactoryGirl.build(:api_created_partner)
      p.generate_random_password
      p.password.should_not be_blank
      p.password_confirmation.should_not be_blank
    end
  end
  
  describe "#generate_username" do
    it "should set a valid username from email address" do
      p = FactoryGirl.build(:partner)
      p.should be_valid
      p.email.should_not be_blank
      p.username = ''
      p.generate_username
      p.username.should_not be_blank
      p.should be_valid
    end
  end
  describe "#logo_url=(URL)" do
    it "opens the file from the URL when saved" do
      url = "http://www.rockthevote.com/assets/images/structure/home_rtv_logo.png"
      p = FactoryGirl.build(:partner)
      mock_io = mock(StringIO)
      mock_uri = mock(URI)
      mock_uri.path { url }
      mock_io.base_uri { mock_uri }
      mock(p).open(url) { mock_io }
      p.logo_url = url
      p.save!
      p.should have_received(:open).with(url)
    end
    it "attaches the URL file as the logo" do
      url = "http://www.rockthevote.com/assets/images/structure/home_rtv_logo.png"
      p = FactoryGirl.build(:partner)
      p.logo_url = url
      p.save!
      p.logo.url.should_not == "/logos/original/missing.png"
    end
    it "adds a validation error if the url is not http" do
      bad_url = "home_rtv_logo_wrong.png"
      p = FactoryGirl.build(:partner)
      p.logo_url = bad_url
      p.should_not be_valid
      p.errors.on(:logo_image_URL).should == "Pleave provide an HTTP url"
    end
    it "adds a validation error if the file can not be downloaded" do
      bad_url = "http://www.rockthevote.com/assets/images/structure/home_rtv_logo_wrong.png"
      p = FactoryGirl.build(:partner)
      p.logo_url = bad_url
      p.should_not be_valid
      p.errors.on(:logo_image_URL).should == "Could not download #{bad_url} for logo"
    end
  end
  
  describe "#valid_api_key?(key)" do
    it "returns false when blank or not matching" do
      partner = FactoryGirl.build(:partner, :api_key=>"")
      partner.valid_api_key?("").should be_false
      partner.api_key="abc"
      partner.valid_api_key?("bca").should be_false
    end
    it "return true when matching" do
      partner = FactoryGirl.build(:partner, :api_key=>"abcdef")
      partner.valid_api_key?("abcdef").should be_true
    end
  end

  describe "widget image" do
    it "is set to default value if none set explicitly" do
      partner = FactoryGirl.build(:partner, :widget_image => nil)
      assert partner.valid?
      assert_equal Partner::DEFAULT_WIDGET_IMAGE_NAME, partner.widget_image_name
      partner.widget_image_name = "rtv100x100v1"
      assert partner.valid?
      assert_equal "rtv100x100v1", partner.widget_image_name
    end

    it "gets name of widget image" do
      partner = FactoryGirl.build(:partner, :widget_image => "rtv-100x100-v1.gif")
      assert_equal "rtv100x100v1", partner.widget_image_name
    end

    it "sets widget_image by name" do
      partner = FactoryGirl.build(:partner, :widget_image => nil)
      partner.widget_image_name = "rtv100x100v1"
      assert_equal "rtv-100x100-v1.gif", partner.widget_image
    end
  end

  describe "logo image" do
    it "has an attached logo" do
      partner = FactoryGirl.build(:partner)
      assert partner.respond_to?(:logo)
      assert_equal Paperclip::Attachment, partner.logo.class
    end

    it "has an error when the logo is not an image type" do
      File.open(File.join(fixture_path, "files/crazy.txt"), "r") do |crazy|
        partner = FactoryGirl.create(:partner)
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
      partner = FactoryGirl.build(:partner)
      File.open(File.join(fixture_path, "files/partner_logo.jpg"), "r") do |logo|
        partner.update_attributes(:logo => logo)
        assert partner.custom_logo?
      end
    end

    it "is false for partners without logos" do
      partner = FactoryGirl.build(:partner)
      assert !partner.custom_logo?
    end
  end

  describe "whitelabeling" do
    describe "Class Methods" do
      describe "#add_whitelabel(partner_id, app_css, reg_css)" do
        before(:each) do
          @partner = FactoryGirl.create(:partner)
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
        partner = FactoryGirl.create(:partner)
        partner.assets_url.should == "/partners/#{partner.id}"
      end
    end
    describe "#assets_path" do
      it "returns the absolute path to the partner directory" do
        partner = FactoryGirl.create(:partner)
        partner.assets_path.should == "#{Rails.root}/public/TEST/partners/#{partner.id}"
      end
    end
    describe "#absolute_application_css_path" do
      it "returns the path RAILS_ROOT/public/TEST/partners/PARTNER_ID/style.css" do
        partner = FactoryGirl.create(:partner)
        partner.absolute_application_css_path.should == "#{Rails.root}/public/TEST/partners/#{partner.id}/application.css"
      end
    end
    describe "#absolute_registration_css_path" do
      it "returns the path RAILS_ROOT/public/TEST/partners/PARTNER_ID/style.css" do
        partner = FactoryGirl.create(:partner)
        partner.absolute_registration_css_path.should == "#{Rails.root}/public/TEST/partners/#{partner.id}/registration.css"
      end
    end
    describe "#absolute_partner_css_path" do
      it "returns the path RAILS_ROOT/public/TEST/partners/PARTNER_ID/partner.css" do
        partner = FactoryGirl.create(:partner)
        partner.absolute_partner_css_path.should == "#{Rails.root}/public/TEST/partners/#{partner.id}/partner.css"
      end
    end
    describe "#css_present?" do
      it "returns true if the both custom css files are present" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        partner.css_present?.should be_true
        File.should have_received(:exists?).with(partner.absolute_application_css_path)
        File.should have_received(:exists?).with(partner.absolute_registration_css_path)
      end
      it "returns false if the custom application css file is not present" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        partner.css_present?.should be_false
      end
      it "returns false if the custom registration css file is not present" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        partner.css_present?.should be_false
      end
      it "returns false if the both custom css files are not present" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        partner.css_present?.should be_false
      end
    end

    describe "#any_css_present?" do
      it "returns true if the either custom css files is present" do
        partner = FactoryGirl.build(:partner)
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
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        stub(File).exists?(partner.absolute_partner_css_path).returns(false)
        partner.any_css_present?.should be_false
      end
    end

    describe "#application_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(true)
        partner.application_css_present?.should be_true
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_application_css_path).returns(false)
        partner.application_css_present?.should be_false
      end
    end
    describe "#registration_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_registration_css_path).returns(true)
        partner.registration_css_present?.should be_true
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_registration_css_path).returns(false)
        partner.registration_css_present?.should be_false
      end
    end
    describe "#partner_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_partner_css_path).returns(true)
        partner.partner_css_present?.should be_true
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        stub(File).exists?(partner.absolute_partner_css_path).returns(false)
        partner.partner_css_present?.should be_false
      end
    end

    describe "#application_css_url" do
      it "is returns the URL for the custom application css" do
        partner = FactoryGirl.build(:partner)
        partner.application_css_url.should == "/partners/#{partner.id}/application.css"
      end
    end
    describe "#registration_css_url" do
      it "is returns the URL for the custom registration css" do
        partner = FactoryGirl.build(:partner)
        partner.registration_css_url.should == "/partners/#{partner.id}/registration.css"
      end
    end
    describe "#partner_css_url" do
      it "is returns the URL for the custom partner css" do
        partner = FactoryGirl.build(:partner)
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
      partner = FactoryGirl.create(:partner)
      registrants = []
      3.times { registrants << FactoryGirl.create(:maximal_registrant, :partner => partner) }
      registrants << FactoryGirl.create(:step_1_registrant, :partner => partner)

      other_partner = FactoryGirl.create(:partner)
      registrants << FactoryGirl.create(:maximal_registrant, :partner => other_partner)

      csv = FasterCSV.parse(partner.generate_registrants_csv)
      assert_equal 5, csv.length # including header
      assert_equal Registrant::CSV_HEADER, csv[0]
      assert_equal registrants[0].to_csv_array, csv[1]
      assert_equal registrants[1].to_csv_array, csv[2]
      assert_equal registrants[2].to_csv_array, csv[3]
      assert_equal registrants[3].to_csv_array, csv[4]
    end
    describe "#generate_registrants_csv_async" do
      before(:each) do
        @partner= FactoryGirl.create(:partner, :csv_ready=>true)
        @t = Time.now
        stub(Time).now { @t }
        stub(Delayed::PerformableMethod).new { "action" }
        stub(Delayed::Job).enqueue
      end
      it "sets the csv_ready for the partner to false" do
        @partner.csv_ready.should be_true
        @partner.generate_registrants_csv_async
        @partner.reload
        @partner.csv_ready.should be_false
      end
      it "sets up a delayed job to generate the csv" do
        @partner.generate_registrants_csv_async
        Delayed::PerformableMethod.should have_received(:new).with(@partner, :generate_registrants_csv_file, [])
        Delayed::Job.should have_received(:enqueue).with("action", Partner::CSV_GENERATION_PRIORITY, @t)
      end
    end
    describe "#generate_csv_file_name" do
      it "generates obfuscated file name" do
        stub(Digest::SHA1).hexdigest { "obfuscate" }
        d = DateTime.now
        Partner.new.generate_csv_file_name(d).should == "csv-obfuscate-#{d.strftime('%Y%m%d-%H%M%S')}.csv"
        #Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{email_address} -- #{home_zip_code}" )
      end
    end
    describe "#csv_file_path" do
      it "returns the path to the file name in the record" do
        @partner = FactoryGirl.create(:partner)        
        stub(@partner).csv_file_name { "a_file_name.ext" }
        stub(@partner).csv_path { "/some/path" }
        stub(FileUtils).mkdir_p
        @partner.csv_file_path.should == "/some/path/a_file_name.ext"
      end
    end
    describe "#csv_path" do
      it "creates the path to the partner csv directory" do
        @partner = FactoryGirl.create(:partner)
        stub(FileUtils).mkdir_p
        @partner.csv_path
        FileUtils.should have_received(:mkdir_p).with(File.join(Rails.root, "csv", @partner.id.to_s))
      end
      it "returns the path to the partner csv directory" do
        @partner = FactoryGirl.create(:partner)
        stub(FileUtils).mkdir_p
        @partner.csv_path.should == File.join(Rails.root, "csv", @partner.id.to_s)
      end
    end
    describe "#generate_registrants_csv_file" do
      before(:each) do
        @partner = FactoryGirl.create(:partner)        
        @t = Time.now
        @file = "mock_object"
        stub(Time).now { @t }
        stub(@partner).generate_csv_file_name { "fn.csv" }
        stub(@partner).generate_registrants_csv { "generated_csv" }
        stub(@partner).csv_ready=
        stub(@partner).save!
        stub(File).open { @file }
        stub(@file).write { true }
        stub(@file).close { true }
        
        stub(Delayed::PerformableMethod).new { "action" }
        stub(Delayed::Job).enqueue
      end
      it "generates obfuscated file names in partner directories with date/time stamp" do
        @partner.generate_registrants_csv_file
        @partner.should have_received(:generate_csv_file_name).with(@t)
      end
      it "saves newest export into csv/[partner_id] directory" do
        @partner.generate_registrants_csv_file
        File.should have_received(:open).with(@partner.csv_file_path, "w")
        @file.should have_received(:write).with("generated_csv")
      end
      it "sets csv_ready to true" do
        @partner.generate_registrants_csv_file
        @partner.should have_received(:csv_ready=).with(true)
      end
      it "saves the obfuscated file name in the partner record" do
        @partner.generate_registrants_csv_file
        @partner.csv_file_name.should == "fn.csv"
        @partner.should have_received(:save!)
      end
      it "sets a delayed job to delete the file" do
        @partner.generate_registrants_csv_file
        Delayed::PerformableMethod.should have_received(:new).with(@partner, :delete_registrants_csv_file, [])
        Delayed::Job.should have_received(:enqueue).with("action", Partner::CSV_GENERATION_PRIORITY, AppConfig.partner_csv_expiration_minutes.from_now)        
      end
    end
  end

  describe "registration statistics" do
    describe "by state" do
      it "should tally registrants by state" do
        partner = FactoryGirl.create(:partner)
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
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

      it "only uses completed/step_5 registrations without finish-with-state for stats" do
        partner = FactoryGirl.create(:partner)
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        3.times do
          reg = FactoryGirl.create(:step_4_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:step_5_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "94101", :party => "Decline to State")
        end
        2.times do 
          reg = FactoryGirl.create(:step_5_registrant, :partner=>partner, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
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
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => other_partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
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
        partner = FactoryGirl.create(:partner)
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Hispano", :locale => "es") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Multi-racial", :locale => "es") }
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Multi-racial", :locale => "es") }
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { FactoryGirl.create(:step_4_registrant, :partner => partner, :race => "Hispanic") }
        2.times { FactoryGirl.create(:step_5_registrant, :partner => partner, :race => "Multi-racial") }
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
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :race => "Hispanic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
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
        partner = FactoryGirl.create(:partner)
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Sr.") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Sra.") }
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Sra.") }
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
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:step_4_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:step_5_registrant, :partner => partner, :name_title => "Sra.") }
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
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
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
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.weeks.ago) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.months.ago) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.years.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal  8, stats[:day_count]
        assert_equal 13, stats[:week_count]
        assert_equal 17, stats[:month_count]
        assert_equal 19, stats[:year_count]
        assert_equal 20, stats[:total_count]
      end

      it "only uses completed/step_5 registrations without finish_with_state for stats" do
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        8.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        8.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal  16, stats[:day_count]
      end

      it "should show percent complete" do
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        8.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal 0.5, stats[:percent_complete]
      end

      it "should not include :initial state registrants in calculations" do
        partner = FactoryGirl.create(:partner)
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago) }
        5.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago) }
        5.times { FactoryGirl.create(:step_1_registrant,  :partner => partner, :created_at => 2.days.ago, :status => :initial) }
        stats = partner.registration_stats_completion_date
        assert_equal   5, stats[:week_count]
        assert_equal 0.5, stats[:percent_complete]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago)
        FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago)
        FactoryGirl.create(:maximal_registrant, :partner => other_partner, :created_at => 2.days.ago)
        stats = partner.registration_stats_completion_date
        assert_equal   1, stats[:week_count]
        assert_equal 0.5, stats[:percent_complete]
      end
    end

    describe "finish-with-state by registration date & state" do
      it "should tally registrants by state and date bucket" do
        partner = FactoryGirl.create(:partner)
        8.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        5.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")
        end
        4.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.weeks.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.months.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")          
        end
        1.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.years.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")          
        end
        stats = partner.registration_stats_finish_with_state_completion_date
        assert_equal "California", stats[0][:state_name]
        assert_equal  8, stats[1][:day_count]
        assert_equal 5, stats[0][:week_count]
        assert_equal 12, stats[1][:month_count]
        assert_equal 7, stats[0][:year_count]
        assert_equal 13, stats[1][:total_count]
      end

      it "only uses completed registrations with finish_with_state for stats" do
        partner = FactoryGirl.create(:partner)
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        8.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        8.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        stats = partner.registration_stats_finish_with_state_completion_date
        assert_equal  "Massachusetts", stats[0][:state_name]
        assert_equal  8, stats[0][:day_count]
        assert_equal  1, stats.size
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
        FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
        FactoryGirl.create(:maximal_registrant, :partner => other_partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
        stats = partner.registration_stats_finish_with_state_completion_date
        assert_equal  "Massachusetts", stats[0][:state_name]
        assert_equal   1, stats[0][:week_count]
        assert_equal  1, stats.size
      end
    end


    describe "by age" do
      it "should tally registrants count and percentage by age bracket on updated_at date" do
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }
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
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        8.times { FactoryGirl.create(:under_18_finished_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        8.times { FactoryGirl.create(:step_1_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_2_registrant, :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:step_3_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:step_4_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }

        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        8.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_5_registrant,  :partner => other_partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

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
        partner = FactoryGirl.create(:partner)
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Democratic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Green") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Other") }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Decline to State") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end

      it "counts states that do not require party as None" do
        partner = FactoryGirl.create(:partner)
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Democratic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Green") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Other") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Decline to State") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "02134") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Democratic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Green") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Other") }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Decline to State") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Other") }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Decline to State") }
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

  describe "Government Partners" do
    describe "Class Methods" do
      describe ".find_by_login(login)" do
        it "returns nil if the found partner is a government partner" do
          FactoryGirl.create(:partner, :is_government_partner=>false, :username=>"partner")
          FactoryGirl.create(:partner, :is_government_partner=>true, :username=>"gov_partner", :government_partner_zip_code_list=>"90000")
          
          Partner.find_by_login("partner").should be_a(Partner)
          Partner.find_by_login("gov_partner").should be_nil
          
        end
      end
      describe ".government" do
        it "returns all government partners" do
          3.times do
            FactoryGirl.create(:partner)
          end
          gps = []
          3.times do
            gps << FactoryGirl.create(:government_partner, :is_government_partner=>true)
          end
          results = Partner.government
          results.should have(3).partners
          gps.each do |gp|
            results.should include(gp)
          end
        end
      end
      describe ".standard" do
        it "returns all standard partners" do
          ngps = []
          existing_partner_count = Partner.count
          3.times do
            ngps << FactoryGirl.create(:partner)
          end
          gps = []
          3.times do
            gps << FactoryGirl.create(:government_partner, :is_government_partner=>true)
          end
          results = Partner.standard
          results.should have(3 + existing_partner_count).partners
          ngps.each do |gp|
            results.should include(gp)
          end
        end
      end
    end
    
    describe "Validations" do
      it "adds an error to government_partner_state_abbrev and government_partner_zip_code_list when both are blank" do
        p = FactoryGirl.create(:government_partner)
        p.government_partner_zip_codes = nil
        p.government_partner_state_id = nil
        p.valid?.should be_false
        p.errors.on(:government_partner_state_abbrev).should_not be_nil
        p.errors.on(:government_partner_zip_code_list).should_not be_nil
      end
      it "ads an error to government_partner_state_abbrev and government_partner_zip_code_list when both are present" do
        p = FactoryGirl.create(:government_partner)
        p.government_partner_state_abbrev="MA"
        p.government_partner_zip_code_list="90000"
        p.valid?.should be_false
        p.errors.on(:government_partner_state_abbrev).should_not be_nil
        p.errors.on(:government_partner_zip_code_list).should_not be_nil
      end
    end
    
    describe "#government_partner_state_abbrev" do
      it "returns the abbreviation for the government_partner_state" do
        p = Partner.new
        p.government_partner_state = GeoState['MA']
        p.government_partner_state_abbrev.should == 'MA'
      end
    end
    describe "#government_partner_state_abbrev=" do
      it "sets the government_partner_state by abbreviation" do
        p = Partner.new
        p.government_partner_state_abbrev= 'MA'        
        p.government_partner_state.should == GeoState['MA']
      end
    end
    describe "#government_partner_zip_code_list" do
      it "returns a new-line separated version of government_partner_zip_codes" do
        p= Partner.new
        p.government_partner_zip_codes = ["12345", "23413-4422", "23415"]
        p.government_partner_zip_code_list.should == ["12345", "23413-4422", "23415"].join("\n")
      end
      it "returns nil when the government_partner_zip_codes is nil" do
        p= Partner.new
        p.government_partner_zip_code_list.should be_nil        
      end
    end
    describe "#government_partner_zip_code_list=" do
      it "cleans a string and sets the government_partner_zip_code_list array" do
        p= Partner.new
        [
          ["242 23423, 23111-342, 23123-1234 4 afe3 235sgsg a3425\n34533 . \\ \n  ef 34335, 34555-1551", ["23423", "23123-1234", "34533", "34335", "34555-1551"]],
          ["12345\n23456\n34567", ["12345", "23456", "34567"]],
          ["22345,23456, 34567", ["22345", "23456", "34567"]],
          ["32345 23456 34567", ["32345", "23456", "34567"]]
        ].each do |string, arr|
            p.government_partner_zip_code_list = string
            p.government_partner_zip_codes.should == arr
            # p.government_partner_zip_code_list = "242 23423, 23111-342, 23123-1234 4 afe3 235sgsg a3425\n34533 . \\ \n  ef 34335, 34555-1551"
            # p.government_partner_zip_codes.should == ["23423", "23123-1234", "34533", "34335", "34555-1551"]
          end
      end
    end
  end

end

