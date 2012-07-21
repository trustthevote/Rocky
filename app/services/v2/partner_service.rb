module V2
  class PartnerService
    INVALID_PARTNER_OR_API_KEY = "Invalid partner ID or api key"
    
    def self.find(query)
      
      partner = find_partner(query[:partner_id], query[:partner_api_key])
      
      return {
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
    
    
    def self.find_partner(partner_id, partner_api_key)
      partner = Partner.find_by_id(partner_id)
      if partner.nil? || !partner.valid_api_key?(partner_api_key)
        raise(ArgumentError.new(V2::PartnerService::INVALID_PARTNER_OR_API_KEY))
      end
      
      return partner
    end
  end
end