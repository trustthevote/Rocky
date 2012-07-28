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
      it 'raises an error if the partner is not found' do
        partner = Factory(:partner)
        stub(Partner).find_by_id { partner }
        stub(partner).valid_api_key? { false }
        lambda {
          V2::PartnerService.find(:partner_id => partner.id, :partner_api_key=>nil)
        }.should raise_error V2::PartnerService::INVALID_PARTNER_OR_API_KEY
      end
    end
    it 'should return data' do
      partner = Factory(:whitelabel_partner)
      V2::PartnerService.find(:partner_id=>partner.id, :partner_api_key=>partner.api_key).should == {
        :org_name     => partner.organization,
        :org_URL          => partner.url,
        :contact_name         => partner.name,
        :contact_email        => partner.email,
        :contact_phone        => partner.phone,
        :contact_address      => partner.address,
        :contact_city         => partner.city,
        :contact_state        => partner.state_abbrev,
        :contact_ZIP     => partner.zip_code,
        :logo_image_URL     => partner.logo.url,
        :banner_image_URL   => "#{PDF_HOST_NAME}/images/widget/#{partner.widget_image}",
        :survey_question_1_en => partner.survey_question_1_en,
        :survey_question_2_en => partner.survey_question_2_en,
        :survey_question_1_es => partner.survey_question_1_es,
        :survey_question_2_es => partner.survey_question_2_es,
        :whitelabeled         => partner.whitelabeled?,
        :rtv_ask_email_opt_in     => partner.rtv_email_opt_in?,
        :partner_ask_email_opt_in => partner.partner_email_opt_in?,
        :rtv_ask_sms_opt_in       => partner.rtv_sms_opt_in?,
        :partner_ask_sms_opt_in   => partner.partner_sms_opt_in?,
        :ask_volunteer   => partner.ask_for_volunteers?,
        :partner_ask_volunteer => partner.partner_ask_for_volunteers?
      }
      
    end
  end
end
