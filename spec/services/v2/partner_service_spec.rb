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
        :email        => partner.email,
        :name         => partner.name,
        :url          => partner.url,
        :address      => partner.address,
        :city         => partner.city,
        :state        => partner.state_abbrev,
        :zip_code     => partner.zip_code,
        :phone        => partner.phone,
        :organization => partner.organization,
        :logo_url     => partner.logo.url,
        :survey_question_1_en => partner.survey_question_1_en,
        :survey_question_1_es => partner.survey_question_1_es,
        :survey_question_2_en => partner.survey_question_2_en,
        :survey_question_2_es => partner.survey_question_2_es,
        :ask_for_volunteers   => partner.ask_for_volunteers?,
        :partner_ask_for_volunteers => partner.partner_ask_for_volunteers?,
        :whitelabeled         => partner.whitelabeled?,
        :rtv_email_opt_in     => partner.rtv_email_opt_in?,
        :partner_email_opt_in => partner.partner_email_opt_in?,
        :rtv_sms_opt_in       => partner.rtv_sms_opt_in?,
        :partner_sms_opt_in   => partner.partner_sms_opt_in?        
      }
      
    end
  end
end
