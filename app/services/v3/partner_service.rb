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
module V3
  class PartnerService
    INVALID_PARTNER_OR_API_KEY = "Invalid partner ID or api key"

    ALLOWED_ATTRS = [:username, 
        :organization,
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
        :partner_ask_for_volunteers,
        :external_tracking_snippet,
        :registration_instructions_url,
        :whitelabeled,
        :from_email,
        :finish_iframe_url,
        :rtv_email_opt_in,
        :rtv_sms_opt_in,
        :ask_for_volunteers,
        :partner_email_opt_in,
        :partner_sms_opt_in,
        :is_government_partner,
        :government_partner_state_id,
        :government_partner_zip_codes,
        :partner_css_download_url]
        
    def self.allowed_attrs 
      ALLOWED_ATTRS + RockyConf.enabled_locales.collect do |locale|
        unless ['en', 'es'].include?(locale.to_s)
          locale = locale.underscore
          [1,2].collect do |num|
            "survey_question_#{num}_#{locale}".to_sym
          end
        end
      end.flatten.compact
    end

    def self.find(query, only_public = false)
      partner = find_partner(query[:partner_id], query[:partner_api_key], only_public)

      data = {
        :id                       => partner.id,
        #:org_name                 => partner.organization,
        #:org_URL                  => partner.url,
        
        :logo_image_URL           => "https://#{RockyConf.pdf_host_name}#{partner.logo.url}",
        :organization                 => partner.organization,
        :url => partner.url,
        :widget_image => partner.widget_image,
        :ask_for_volunteers => partner.ask_for_volunteers,
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
        :registration_instructions_url => partner.registration_instructions_url
      }
      
      
      RockyConf.enabled_locales.each do |loc|
        data["survey_question_1_#{loc}".to_sym] = partner.send("survey_question_1_#{loc}")
        data["survey_question_2_#{loc}".to_sym] = partner.send("survey_question_2_#{loc}")
      end

      if !only_public
        data.merge!({
          :name           => partner.name,
          :address => partner.address,
          :city   => partner.city,
          :state_id => partner.state_id,
          :zip_code => partner.zip_code,
          :phone => partner.phone,
        
          :whitelabeled             => partner.whitelabeled?,
        
          :application_css_present  => partner.application_css_present?,
          :application_css_url      => partner.application_css_url,
          :registration_css_present => partner.registration_css_present?,
          :registration_css_url     => partner.registration_css_url,
          :partner_css_present      => partner.partner_css_present?,
          :partner_css_url          => partner.partner_css_url,
        
          :external_tracking_snippet => partner.external_tracking_snippet,
        
          :primary =>partner.primary?,
          
        })
      end

      return data
    end


    def self.find_partner(partner_id, partner_api_key, only_public=false)
      partner = Partner.find_by_id(partner_id)
      if partner.nil? || (!partner.valid_api_key?(partner_api_key) && !only_public)
        raise(ArgumentError.new(V3::PartnerService::INVALID_PARTNER_OR_API_KEY))
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
      attrs.symbolize_keys! if attrs.respond_to?(:symbolize_keys!)

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
      raise V3::RegistrationService::ValidationError.new(field, error.last)
    end

    def self.block_protected_attributes(attrs)
      attrs.each do |key,val|
        if !allowed_attrs.include?(key.to_sym)
          raise ActiveRecord::UnknownAttributeError.new("unknown attribute: #{key.to_s}")
        end
      end
    end


  end
end
