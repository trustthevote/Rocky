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
module V1
  class RegistrationService

    INVALID_PARTNER_OR_PASSWORD = "Invalid partner ID or password"

    # Validation error
    class ValidationError < StandardError
      attr_reader :field

      def initialize(field, message)
        super(message)
        @field = field
      end
    end

    # Creates a record and returns it.
    def self.create_record(data)
      data ||= {}
      block_protected_attributes(data)

      attrs = data_to_attrs(data)
      reg = Registrant.build_from_api_data(attrs)

      if reg.save
        reg.enqueue_complete_registration_via_api
      else
        validate_language(reg)
        raise_validation_error(reg)
      end

      reg
    end

    # Lists records for the given partner
    def self.find_records(query)
      query ||= {}
      partner = find_partner(query[:partner_id], query[:partner_password])

      regs = partner.registrants

      if since = query[:since]
        regs = regs.all(:conditions => [ "created_at >= ?", Time.parse(since) ])
      end

      regs.map do |reg|
        { :status               => reg.extended_status,
          :create_time          => reg.created_at.to_s,
          :complete_time        => reg.completed_at.to_s,
          :lang                 => reg.locale,
          :first_reg            => reg.first_registration?,
          :home_zip_code        => reg.home_zip_code,
          :us_citizen           => reg.us_citizen?,
          :name_title           => reg.name_title,
          :first_name           => reg.first_name,
          :middle_name          => reg.middle_name,
          :last_name            => reg.last_name,
          :name_suffix          => reg.name_suffix,
          :home_address         => reg.home_address,
          :home_unit            => reg.home_unit,
          :home_city            => reg.home_city,
          :home_state_id        => reg.home_state_id,
          :has_mailing_address  => reg.has_mailing_address,
          :mailing_address      => reg.mailing_address,
          :mailing_unit         => reg.mailing_unit,
          :mailing_city         => reg.mailing_city,
          :mailing_state_id     => reg.mailing_state_id,
          :mailing_zip_code     => reg.mailing_zip_code,
          :race                 => reg.race,
          :party                => reg.party,
          :phone                => reg.phone,
          :phone_type           => reg.phone_type,
          :email_address        => reg.email_address,
          :opt_in_email         => reg.opt_in_email,
          :opt_in_sms           => reg.opt_in_sms,
          :survey_question_1    => partner.send("survey_question_1_#{reg.locale}"),
          :survey_answer_1      => reg.survey_answer_1,
          :survey_question_2    => partner.send("survey_question_1_#{reg.locale}"),
          :survey_answer_2      => reg.survey_answer_2,
          :volunteer            => reg.volunteer? }
      end
    end

    private

    def self.block_protected_attributes(attrs)
      raise ActiveRecord::UnknownAttributeError.new('unknown attribute: state_id_number') if attrs[:state_id_number].present?
    end

    def self.validate_language(reg)
      if reg.locale.nil?
        reg.errors.clear
        reg.errors.add(:lang, :blank)
        raise_validation_error(reg)
      end

      raise UnsupportedLanguageError if !reg.errors[:locale].empty?
    end

    def self.raise_validation_error(reg, error = reg.errors.sort.first)
      field = error.first

      # convert state_id_number into id_number
      field = 'id_number' if field == 'state_id_number'

      raise ValidationError.new(field, error.last)
    end

    def self.data_to_attrs(data)
      attrs = data.clone

      if l = attrs.delete(:lang)
        attrs[:locale] = l
      end

      if l = attrs.delete(:partner_tracking_id)
        attrs[:tracking_source] = l
      end

      if l = attrs.delete(:id_number)
        attrs[:state_id_number] = l
      end

      attrs = state_convert(attrs, :home_state)
      attrs = state_convert(attrs, :mailing_state)
      attrs = state_convert(attrs, :prev_state)

      attrs
    end

    def self.state_convert(attrs, field)
      l1 = attrs.delete(field)
      l2 = attrs.delete("#{field}_id".to_sym)
      l  = l2 || l1
      if l
        attrs["#{field}_id"] = GeoState[l.to_s.upcase].try(:id)
      end
      attrs
    end

    def self.find_partner(partner_id, password)
      partner = Partner.first(:conditions => { :id => partner_id })

      if !partner || !partner.valid_password?(password)
        raise ArgumentError.new(INVALID_PARTNER_OR_PASSWORD)
      end

      partner
    end
  end
end