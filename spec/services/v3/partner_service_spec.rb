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

describe V3::PartnerService do
  describe "#find" do
    context 'error' do
      it 'raises an error if the partner is not found' do
        lambda {
          V3::PartnerService.find(:partner_id => 0)
        }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY
      end
      it 'raises an error if the api key is invalid' do
        partner = FactoryGirl.create(:partner)
        Partner.stub(:find_by_id) { partner }
        partner.stub(:valid_api_key?) { false }
        lambda {
          V3::PartnerService.find(:partner_id => partner.id, :partner_api_key=>nil)
        }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY
      end
    end
    it 'should return all data and all columns' do
      partner = FactoryGirl.create(:whitelabel_partner)
      expected_response = {
        :id                       => partner.id,
        :logo_image_URL           => "#{partner.logo.url}",
        :custom_logo              => partner.custom_logo?,
        :header_logo_url          => partner.logo(:header),
        :whitelabeled             => partner.whitelabeled?,

        :application_css_present  => partner.application_css_present?,
        :application_css_url      => partner.application_css_url,
        :registration_css_present => partner.registration_css_present?,
        :registration_css_url     => partner.registration_css_url,
        :partner_css_present      => partner.partner_css_present?,
        :partner_css_url          => partner.partner_css_url,
        
        :primary =>partner.primary?,
        :organization                 => partner.organization,
        :url => partner.url,
        :name => partner.name,
        :address => partner.address,
        :city   => partner.city,
        :state_id => partner.state_id,
        :zip_code => partner.zip_code,
        :phone => partner.phone,
        :ask_for_volunteers => partner.ask_for_volunteers,
        :widget_image => partner.widget_image,
        :partner_ask_for_volunteers => partner.partner_ask_for_volunteers,
        :rtv_email_opt_in => partner.rtv_email_opt_in,
        :partner_email_opt_in => partner.partner_email_opt_in,
        :rtv_sms_opt_in => partner.rtv_sms_opt_in,
        :partner_sms_opt_in => partner.partner_sms_opt_in,
        :privacy_url => partner.privacy_url,
        :finish_iframe_url => partner.finish_iframe_url,
        :is_government_partner => partner.is_government_partner?,
        :government_partner_state_id => partner.government_partner_state_id,
        :government_partner_zip_codes => partner.government_partner_zip_codes,
        :external_tracking_snippet => partner.external_tracking_snippet,
        :registration_instructions_url => partner.registration_instructions_url
      }
      
      
      RockyConf.enabled_locales.each do |loc|
        expected_response["survey_question_1_#{loc}".to_sym] = partner.send("survey_question_1_#{loc}")
        expected_response["survey_question_2_#{loc}".to_sym] = partner.send("survey_question_2_#{loc}")
      end
      
      response = V3::PartnerService.find(:partner_id => partner.id, :partner_api_key => partner.api_key)
      expected_response.each do |key, value|
        response[key].should == value
      end
      
    end

    it 'should return all V2 versions of the data' do
      partner = FactoryGirl.create(:whitelabel_partner)
      expected_response = {
        :org_name                 => partner.organization,
        :org_URL                  => partner.url,
        :contact_name             => partner.name,
        :contact_email            => partner.email,
        :contact_phone            => partner.phone,
        :contact_address          => partner.address,
        :contact_city             => partner.city,
        :contact_state            => partner.state_abbrev,
        :contact_ZIP              => partner.zip_code,
        :logo_image_URL           => "#{partner.logo.url}",
        :whitelabeled             => partner.whitelabeled?,
        :rtv_ask_email_opt_in     => partner.rtv_email_opt_in?,
        :partner_ask_email_opt_in => partner.partner_email_opt_in?,
        :rtv_ask_sms_opt_in       => partner.rtv_sms_opt_in?,
        :partner_ask_sms_opt_in   => partner.partner_sms_opt_in?,
        :rtv_ask_volunteer        => partner.ask_for_volunteers?,
        :partner_ask_volunteer    => partner.partner_ask_for_volunteers?
      }
      
      RockyConf.enabled_locales.each do |loc|
        expected_response["survey_question_1_#{loc}".to_sym] = partner.send("survey_question_1_#{loc}")
        expected_response["survey_question_2_#{loc}".to_sym] = partner.send("survey_question_2_#{loc}")
      end
      
      response = V3::PartnerService.find(:partner_id => partner.id, :partner_api_key => partner.api_key)
      expected_response.each do |key, value|
        response[key].should == value
      end
      
    end

    it 'should return only public data' do
      partner = FactoryGirl.create(:whitelabel_partner)
      
      expected_response = {
        :id                       => partner.id,
        :org_name                 => partner.organization,
        :org_URL                  => partner.url,
        :whitelabeled             => partner.whitelabeled?,
        :logo_image_URL           => "#{partner.logo.url}",
        
        :organization                 => partner.organization,
        :url => partner.url,

        :ask_for_volunteers => partner.ask_for_volunteers,
        :widget_image => partner.widget_image,
        :partner_ask_for_volunteers => partner.partner_ask_for_volunteers,
        :rtv_email_opt_in => partner.rtv_email_opt_in,
        :partner_email_opt_in => partner.partner_email_opt_in,
        :rtv_sms_opt_in => partner.rtv_sms_opt_in,
        :partner_sms_opt_in => partner.partner_sms_opt_in,
        
        :rtv_ask_email_opt_in     => partner.rtv_email_opt_in?,
        :partner_ask_email_opt_in => partner.partner_email_opt_in?,
        :rtv_ask_sms_opt_in       => partner.rtv_sms_opt_in?,
        :partner_ask_sms_opt_in   => partner.partner_sms_opt_in?,
        :rtv_ask_volunteer        => partner.ask_for_volunteers?,
        :partner_ask_volunteer    => partner.partner_ask_for_volunteers?,
        
        :org_privacy_url => partner.privacy_url,
        :privacy_url => partner.privacy_url,
        
        :finish_iframe_url => partner.finish_iframe_url,
        :is_government_partner => partner.is_government_partner?,
        :government_partner_state_id => partner.government_partner_state_id,
        :government_partner_zip_codes => partner.government_partner_zip_codes,

        :registration_instructions_url => partner.registration_instructions_url
      }
      
      RockyConf.enabled_locales.each do |loc|
        expected_response["survey_question_1_#{loc}".to_sym] = partner.send("survey_question_1_#{loc}")
        expected_response["survey_question_2_#{loc}".to_sym] = partner.send("survey_question_2_#{loc}")
      end
      
      V3::PartnerService.find({ :partner_id => partner.id, :partner_api_key => partner.api_key }, true).should == expected_response
    end
  end

  describe '#data_to_attrs' do
    specify { V3::PartnerService.send(:data_to_attrs, {:org_name=>"Name"}).should == {:organization=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:org_URL=>"Name"}).should == {:url=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:org_privacy_url=>"Name"}).should == {:privacy_url=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:logo_image_URL=>"Name"}).should == {:logo_url=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_email=>"Name"}).should == {:email=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_name=>"Name"}).should == {:name=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_address=>"Name"}).should == {:address=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_city=>"Name"}).should == {:city=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_phone=>"Name"}).should == {:phone=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_state=>"nJ"}).should == {:state_id=>31} }
    specify { V3::PartnerService.send(:data_to_attrs, {:contact_ZIP=>"Name"}).should == {:zip_code=>"Name"} }
    specify { V3::PartnerService.send(:data_to_attrs, {:partner_ask_volunteer=>true}).should == {:partner_ask_for_volunteers=>true} }
    #banner_image_URL
  end



  describe "#create" do
    it 'should raise an error if the field is unknown' do
      begin
        V3::PartnerService.create_record(:unknown_field => 'fieldval')
        fail "UnknownAttributeError expected"
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == 'unknown attribute: unknown_field'
      end
    end




    it 'should raise validation errors when the record is invalid' do
      begin
        V3::PartnerService.create_record({})
        fail 'ValidationError is expected'
      rescue V3::RegistrationService::ValidationError => e
        e.field.to_s.should    == 'address'
        e.message.should  == "Address can't be blank."
      end
    end

    it "raise validation errors if the logo URL is not a URI" do
      begin
        partner = FactoryGirl.build(:api_created_partner, :logo_url=>"no_url")
        Partner.stub(:new).with({}) { partner }
        V3::PartnerService.create_record({})
        fail 'ValidationError is expected'
      rescue V3::RegistrationService::ValidationError => e
        e.field.to_s.should    == 'logo_image_URL'
        e.message.should  == "Pleave provide an HTTP url"
      end
    end
    it "raise validation errors if the logo URL can not be downloaded" do
      begin
        partner = FactoryGirl.build(:api_created_partner, :logo_url=>"http://no_url")
        Partner.stub(:new).with({}) { partner }
        V3::PartnerService.create_record({})
        fail 'ValidationError is expected'
      rescue V3::RegistrationService::ValidationError => e
        e.field.to_s.should    == 'logo_image_URL'
        e.message.should  == "Could not download http://no_url for logo"
      end
    end

    it 'does not allow parameters except the expected ones to be set' do
      begin
        V3::PartnerService.create_record({:survey_question_1=>true})
        fail 'UnknownAttributeError expected'
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == 'unknown attribute: survey_question_1'
      end
    end



    context 'complete record' do
      let(:params) do
        {
          username: "a-custom-username",
          organization: "Org Name",
          url: "http://www.google.com",
          privacy_url: "http://www.google.com/privacy",
          logo_url: "http://www.rockthevote.com/assets/images/structure/home_rtv_logo.png",
          name: "Contact Name",
          email: "contact_email@rtv.org",
          phone: "123 234 3456",
          address: "123 Main St",
          city: "Boston",
          state_id: GeoState["MA"].id,
          zip_code: "02110",
          widget_image: "rtv-234x60-v1.gif",
          survey_question_1_en:  "One?",
          survey_question_2_en:  "Two?",
          survey_question_1_es:  "Uno?",
          survey_question_2_es:  "Dos?",
          partner_ask_for_volunteers: true,
          external_tracking_snippet: "<code>snippet</code>",
          registration_instructions_url: "http://register.rockthevote.com/reg-instructions?l=<LOCALE>&s=<STATE>",
          survey_question_2_zh_tw: "%E9%9B%BB%E5%AD%90%E9%83%B5%E4%BB%B6%E5%9C%B0%E5%9D%80",
          survey_question_1_ko: "KO One",
          survey_question_2_ko: "KO Two",
          whitelabeled: true,
          from_email: "custom-from@rtv.org",
          finish_iframe_url: "http://example.com/iFrame-url",
          rtv_email_opt_in: false,
          rtv_sms_opt_in: false,
          ask_for_volunteers: true,
          partner_email_opt_in: true,
          partner_sms_opt_in: true,
          is_government_partner: true,
          government_partner_zip_codes: ["02113", "02110"],
          partner_css_download_url: "http://www.google.com"
        }
      end

      it 'should save the record' do
        p = V3::PartnerService.create_record(params)
        p.survey_question_1_ko.should == "KO One"
        p.survey_question_2_ko.should == "KO Two"
        params2 = params.dup
        params2.delete(:government_partner_zip_codes)
        params2[:government_partner_state_id] = GeoState["MA"].id
        params2[:email] = "contact_email+2@rtv.org"
        V3::PartnerService.create_record(params2).should
      end
    end



  end

end
