module V2
  class PartnerService
    INVALID_PARTNER_OR_API_KEY = "Invalid partner ID or api key"
    
    def self.find(query)
      
      partner = find_partner(query[:partner_id], query[:partner_api_key])
      
      return {
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
    
    
    def self.find_partner(partner_id, partner_api_key)
      partner = Partner.find_by_id(partner_id)
      if partner.nil? || !partner.valid_api_key?(partner_api_key)
        raise(ArgumentError.new(V2::PartnerService::INVALID_PARTNER_OR_API_KEY))
      end
      
      return partner
    end
  end
end