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

describe V2::PartnerService do
  describe "#find" do
    context 'error' do
      it 'raises an error if the partner is not found' do
        lambda {
          V2::PartnerService.find(:partner_id => 0)
        }.should raise_error V2::PartnerService::INVALID_PARTNER_OR_API_KEY
      end
      it 'raises an error if the api key is invalid' do
        partner = FactoryGirl.create(:partner)
        stub(Partner).find_by_id { partner }
        stub(partner).valid_api_key? { false }
        lambda {
          V2::PartnerService.find(:partner_id => partner.id, :partner_api_key=>nil)
        }.should raise_error V2::PartnerService::INVALID_PARTNER_OR_API_KEY
      end
    end
    it 'should return all data' do
      partner = FactoryGirl.create(:whitelabel_partner)
      V2::PartnerService.find(:partner_id => partner.id, :partner_api_key => partner.api_key).should == {
        :org_name                 => partner.organization,
        :org_URL                  => partner.url,
        :contact_name             => partner.name,
        :contact_email            => partner.email,
        :contact_phone            => partner.phone,
        :contact_address          => partner.address,
        :contact_city             => partner.city,
        :contact_state            => partner.state_abbrev,
        :contact_ZIP              => partner.zip_code,
        :logo_image_URL           => "https://#{PDF_HOST_NAME}#{partner.logo.url}",
        :survey_question_1_en     => partner.survey_question_1_en,
        :survey_question_2_en     => partner.survey_question_2_en,
        :survey_question_1_es     => partner.survey_question_1_es,
        :survey_question_2_es     => partner.survey_question_2_es,
        :whitelabeled             => partner.whitelabeled?,
        :rtv_ask_email_opt_in     => partner.rtv_email_opt_in?,
        :partner_ask_email_opt_in => partner.partner_email_opt_in?,
        :rtv_ask_sms_opt_in       => partner.rtv_sms_opt_in?,
        :partner_ask_sms_opt_in   => partner.partner_sms_opt_in?,
        :rtv_ask_volunteer        => partner.ask_for_volunteers?,
        :partner_ask_volunteer    => partner.partner_ask_for_volunteers?
      }
    end

    it 'should return only public data' do
      partner = FactoryGirl.create(:whitelabel_partner)
      V2::PartnerService.find({ :partner_id => partner.id, :partner_api_key => partner.api_key }, true).should == {
        :org_name                 => partner.organization,
        :org_URL                  => partner.url,
        :org_privacy_url          => partner.privacy_url,
        :logo_image_URL           => "https://#{PDF_HOST_NAME}#{partner.logo.url}",
        :survey_question_1_en     => partner.survey_question_1_en,
        :survey_question_2_en     => partner.survey_question_2_en,
        :survey_question_1_es     => partner.survey_question_1_es,
        :survey_question_2_es     => partner.survey_question_2_es,
        :whitelabeled             => partner.whitelabeled?,
        :rtv_ask_email_opt_in     => partner.rtv_email_opt_in?,
        :partner_ask_email_opt_in => partner.partner_email_opt_in?,
        :rtv_ask_sms_opt_in       => partner.rtv_sms_opt_in?,
        :partner_ask_sms_opt_in   => partner.partner_sms_opt_in?,
        :rtv_ask_volunteer        => partner.ask_for_volunteers?,
        :partner_ask_volunteer    => partner.partner_ask_for_volunteers?
      }
    end
  end

  describe '#data_to_attrs' do
    specify { V2::PartnerService.send(:data_to_attrs, {:org_name=>"Name"}).should == {:organization=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:org_URL=>"Name"}).should == {:url=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:org_privacy_url=>"Name"}).should == {:privacy_url=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:logo_image_URL=>"Name"}).should == {:logo_url=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_email=>"Name"}).should == {:email=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_name=>"Name"}).should == {:name=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_address=>"Name"}).should == {:address=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_city=>"Name"}).should == {:city=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_phone=>"Name"}).should == {:phone=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_state=>"nJ"}).should == {:state_id=>31} }
    specify { V2::PartnerService.send(:data_to_attrs, {:contact_ZIP=>"Name"}).should == {:zip_code=>"Name"} }
    specify { V2::PartnerService.send(:data_to_attrs, {:partner_ask_volunteer=>true}).should == {:partner_ask_for_volunteers=>true} }
    #banner_image_URL
  end



  describe "#create" do
    it 'should raise an error if the field is unknown' do
      begin
        V2::PartnerService.create_record(:unknown_field => 'fieldval')
        fail "UnknownAttributeError expected"
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == 'unknown attribute: unknown_field'
      end
    end




    it 'should raise validation errors when the record is invalid' do
      begin
        V2::PartnerService.create_record({})
        fail 'ValidationError is expected'
      rescue V2::RegistrationService::ValidationError => e
        e.field.should    == 'address'
        e.message.should  == "Address can't be blank."
      end
    end

    it "raise validation errors if the logo URL is not a URI" do
      begin
        partner = FactoryGirl.build(:api_created_partner, :logo_url=>"no_url")
        mock(Partner).new({}) { partner }
        V2::PartnerService.create_record({})
        fail 'ValidationError is expected'
      rescue V2::RegistrationService::ValidationError => e
        e.field.should    == 'logo_image_URL'
        e.message.should  == "Pleave provide an HTTP url"
      end
    end
    it "raise validation errors if the logo URL can not be downloaded" do
      begin
        partner = FactoryGirl.build(:api_created_partner, :logo_url=>"http://no_url")
        mock(Partner).new({}) { partner }
        V2::PartnerService.create_record({})
        fail 'ValidationError is expected'
      rescue V2::RegistrationService::ValidationError => e
        e.field.should    == 'logo_image_URL'
        e.message.should  == "Could not download http://no_url for logo"
      end
    end

    it 'does not allow parameters except the expected ones to be set' do
      begin
        V2::PartnerService.create_record({:whitelabeled=>true})
        fail 'UnknownAttributeError expected'
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == 'unknown attribute: whitelabeled'
      end
    end




    context 'complete record' do
      before { @partner = FactoryGirl.build(:api_created_partner) }
      before { mock(Partner).new({}) { @partner } }

      it 'should save the record' do
        V2::PartnerService.create_record({}).should
      end
    end



  end

end
