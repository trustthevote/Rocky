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
class StateRequirements

  INVALID_STATE_ID  = "Invalid state ID"
  INVALID_ZIP       = "Invalid ZIP code"
  NO_ZIP_MATCH      = "ZIP code doesn't match the state"
  MISSING_ID_OR_ZIP = "Either home_state_id or home_zip_code is required"
  BAD_DOB_FORMAT    = "Date of birth has invalid format (yyyy-mm-dd is expected)"

  def self.find(query)
    state   = find_state(query)
    locale  = get_locale(state, query[:lang])

    validate_participation(state, locale)
    validate_age(state, query[:date_of_birth], locale)

    { :requires_race =>      state.requires_race?,
      :requires_race_msg =>  locale.race_tooltip,
      :requires_party =>     state.requires_party?,
      :requires_party_msg => locale.party_tooltip,
      :no_party_msg =>       locale.no_party,
      :party_list =>         locale.parties,
      :id_length_min =>      state.id_length_min,
      :id_length_max =>      state.id_length_max,
      :id_number_msg =>      locale.id_number_tooltip,
      :sos_address =>        state.registrar_address,
      :sos_phone =>          state.registrar_phone,
      :sos_url =>            state.registrar_url,
      :sub_18_msg =>         locale.sub_18 }
  end

  private

  # Finds the state by either ID or zip code
  def self.find_state(query)
    query  ||= {}
    state_id = query[:home_state_id].to_s.upcase
    zip_code = query[:home_zip_code]

    if !state_id.blank?
      id_state  = GeoState[state_id] || raise(ArgumentError.new(INVALID_STATE_ID))
    end

    if !zip_code.blank?
      raise ArgumentError.new(INVALID_ZIP) unless zip_code.strip =~ /^\d{5}([\-]?\d{4})?$/
      zip_state = GeoState.for_zip_code(zip_code) || raise(ArgumentError.new(INVALID_ZIP))
    end

    if state_id.blank? && zip_code.blank?
      # neither given
      raise ArgumentError.new(MISSING_ID_OR_ZIP)
    end

    if id_state && zip_state && id_state != zip_state
      raise ArgumentError.new(NO_ZIP_MATCH)
    end

    id_state || zip_state
  end

  def self.get_locale(state, lang)
    state.localizations.find_by_locale(lang.to_s.downcase) || raise(UnsupportedLanguageError)
  end

  def self.validate_age(state, dob, locale)
    return if dob.blank?

    begin
      date = Date.parse(dob)
    rescue ArgumentError
      raise ArgumentError.new(BAD_DOB_FORMAT)
    end

    if date > 18.years.ago.to_date
      raise ArgumentError.new(locale.sub_18)
    end
  end

  def self.validate_participation(state, locale)
    unless state.participating?
      raise ArgumentError.new(locale.not_participating_tooltip)
    end
  end
end
