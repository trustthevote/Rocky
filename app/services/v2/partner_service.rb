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
module V2
  class PartnerService
    INVALID_PARTNER_OR_API_KEY = "Invalid partner ID or api key"

    ALLOWED_ATTRS = [:organization,
        :url,
        :privacy_url,
        :logo_url,
        :name,
        :email,
        :phone,
        :address,
        :city,
        :state_id,
        :zip_code,
        :widget_image,
        :survey_question_1_en,
        :survey_question_2_en,
        :survey_question_1_es,
        :survey_question_2_es,
        :partner_ask_for_volunteers]

    def self.find(query, only_public = false)

      partner = find_partner(query[:partner_id], query[:partner_api_key], only_public)

      data = {
        :org_name                 => partner.organization,
        :org_URL                  => partner.url,
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

      if only_public
        data.merge!({
          :org_privacy_url        => partner.privacy_url
        })
      else
        data.merge!({
          :contact_name           => partner.name,
          :contact_email          => partner.email,
          :contact_phone          => partner.phone,
          :contact_address        => partner.address,
          :contact_city           => partner.city,
          :contact_state          => partner.state_abbrev,
          :contact_ZIP            => partner.zip_code
        })
      end

      return data
    end


    def self.find_partner(partner_id, partner_api_key, only_public=false)
      partner = Partner.find_by_id(partner_id)
      if partner.nil? || (!partner.valid_api_key?(partner_api_key) && !only_public)
        raise(ArgumentError.new(V2::PartnerService::INVALID_PARTNER_OR_API_KEY))
      end

      return partner
    end

    def self.create_record(data)
      data ||= {}

      attrs = data_to_attrs(data)

      block_protected_attributes(attrs)


      p = Partner.new(attrs)

      p.generate_username
      p.generate_random_password


      if !p.save
        raise_validation_error(p)
      end
      p
    end

  private
    def self.data_to_attrs(data)
      attrs = data.clone
      attrs.symbolize_keys!

      [[:org_name, :organization],
      [:org_URL, :url],
      [:org_privacy_url, :privacy_url],
      [:logo_image_URL, :logo_url],
      [:contact_name, :name],
      [:contact_email, :email],
      [:contact_address, :address],
      [:contact_phone, :phone],
      [:contact_city, :city],
      [:contact_ZIP, :zip_code],
      [:partner_ask_volunteer, :partner_ask_for_volunteers]].each do |data_key, attr_key|
        val = attrs.delete(data_key)
        if !val.nil?
          attrs[attr_key] = val
        end
      end

      attrs = state_convert(attrs,[:contact_state, :state_id])

      attrs
    end

    def self.state_convert(attrs, field_keys)
      l = attrs.delete(field_keys[0])
      if l
        attrs[field_keys[1]] = GeoState[l.to_s.upcase].try(:id)
      end
      attrs
    end

    def self.raise_validation_error(p, error = p.errors.sort.first)
      field = error.first
      raise V2::RegistrationService::ValidationError.new(field, error.last)
    end

    def self.block_protected_attributes(attrs)
      attrs.each do |key,val|
        if !ALLOWED_ATTRS.include?(key.to_sym)
          raise ActiveRecord::UnknownAttributeError.new("unknown attribute: #{key.to_s}")
        end
      end
    end


  end
end
