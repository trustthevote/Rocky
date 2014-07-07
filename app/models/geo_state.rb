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
class GeoState < ActiveRecord::Base

  has_many :localizations, :class_name => 'StateLocalization', :foreign_key => 'state_id'
  
  delegate :online_reg_url, :redirect_to_online_reg_url, :has_ovr_pre_check?, :ovr_pre_check, :decorate_registrant, :enabled_for_language?, :to=>:state_customization

  def self.[](id_or_abbrev)
    init_all_states
    case id_or_abbrev
    when Fixnum
      @@all_states_by_id[id_or_abbrev]
    when String
      @@all_states_by_abbrev[id_or_abbrev]
    end
  end
  
  def self.collection_for_select
    init_all_states
    @@all_states_by_abbrev.map { |abbrev, state| [state.name, abbrev] }.sort
  end

  def self.init_all_states
    @@all_states_by_id ||= all.inject([]) { |arr,state| arr[state.id] = state; arr }
    @@all_states_by_abbrev ||= @@all_states_by_id[1..-1].index_by(&:abbreviation)
  end

  def self.reset_all_states
    @@all_states_by_id = nil
    @@all_states_by_abbrev = nil
  end

  # ZIP codes
  
  def self.read_zip_file(file_name)
    lines = File.new(File.join(Rails.root, "data/zip_codes/#{file_name}")).readlines
    Hash[*(lines.collect {|line| line.chomp.split(',')}.flatten)]
  end
  
  def self.county_registrar_addresses
    @@county_registrar_addresses ||= read_county_registrar_addresses
  end
  def self.reset_county_registrar_addresses
    @@county_registrar_addresses = nil
  end
  
  def self.read_county_registrar_addresses
    #COUNTY,STREET 1,STREET 2,CITY,STATE,ZIP,PHONE
    cra = {}
    errors = []
    CSV.foreach(county_addresses_file, {:headers=>:first_row}) do |cased_row|
      row = {}
      cased_row.each {|k,v| row[k.downcase] = v.to_s.strip }
      cra[row["state"]] ||= {}
      county_file_name = ActiveSupport::Multibyte::Chars.new(row["county"]).mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'')
      
      if county_zip_codes[row["state"]].nil?
        errors << "State #{row["state"]} missing!"
      else
        county_name = get_county_name_from_zip_codes(row["state"], county_file_name, errors)
        
        if !county_name.nil?
          if cra[row["state"]].has_key?(county_name)
            raise "Duplicate county #{row["county"]} for state #{row["state"]}"
          end
          
          cra[row["state"]][county_name] = [[row["street 1"], row["street 2"], "#{row["city"]}, #{row["state"]} #{row["zip"]}"].join("\n"), county_zip_codes[row["state"]][county_name]]
        else 
          county_name = get_city_name_from_zip_codes(row["state"], county_file_name, errors)
          if !county_name.nil?
            if cra[row["state"]].has_key?(county_name)
              raise "Duplicate city #{row["county"]} for state #{row["state"]}"
            end
        
            cra[row["state"]][county_name] = [[row["street 1"], row["street 2"], "#{row["city"]}, #{row["state"]} #{row["zip"]}"].join("\n"), city_zip_codes[row["state"]][county_name]]
          end
        end
      end
    end
    
    if errors.any?
      raise "The following counties are missing from the zip code database:\n" + errors.join("\n")
    end
    cra
  end
  
  def self.get_county_name_from_zip_codes(state, county_name, errors)
    attempted_name = county_name
    county_name = county_name.to_s.downcase.gsub("&", "and")
    if county_zip_codes[state].has_key?(county_name)
      return county_name
    end
    
    # try the "st." substitution
    st_county_name = county_name.to_s.downcase.gsub(/st\./, "saint")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = county_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    
    # try adding suffix
    county_name = county_name + ((state == "LA") ? " parish" : " county")
    if county_zip_codes[state].has_key?(county_name)
      return county_name
    end

    # try the "st." substitution
    st_county_name = county_name.to_s.downcase.gsub(/st\./, "saint")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = county_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end

    
    return nil
  end
  
  def self.get_city_name_from_zip_codes(state, county_name, errors)
    attempted_name = county_name
    county_name = county_name.to_s.downcase
    if city_zip_codes[state].has_key?(county_name)
      return county_name
    end
    
    
    # try the "st." substitution
    st_county_name = county_name.to_s.downcase.gsub(/st\./, "saint")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = county_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    
    # try removing " City" and "City of "
    city_name = county_name.gsub(/^city\s+of\s+/,'').gsub(/\s+city$/,'')
    if city_zip_codes[state].has_key?(city_name)
      return city_name
    end
    
    # try the "st." substitution
    st_county_name = city_name.to_s.downcase.gsub(/st\./, "saint")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = city_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    
    
    errors << "#{state}: #{attempted_name}"
    return nil
  end
  
  def self.county_addresses_file
    Rails.root.join("data/zip_codes/county_addresses.csv")
  end
  def self.zip_code_database_file
    Rails.root.join("data/zip_codes/zip_code_database.csv")
  end
  
  def self.county_zip_codes
    @@county_zip_codes ||= []
    if @@county_zip_codes.empty?
      @@county_zip_codes, @@city_zip_codes = read_zip_code_database
    end
    return @@county_zip_codes
  end
  
  def self.city_zip_codes
    @@city_zip_codes ||= []
    if @@city_zip_codes.empty?
      @@county_zip_codes, @@city_zip_codes = read_zip_code_database
    end
    return @@city_zip_codes
  end
  
  def self.reset_county_zip_codes
    @@county_zip_codes = nil
  end
  
  def self.read_zip_code_database
    #1. Read list of counties from zip_code_database
    #2. Read county-addresses into memory
    #3. Make sure all county-address counties are in zip database
    #4. Map county/state/zip/addresses and commit to DB
    counties = {}
    cities = {}
    CSV.foreach(zip_code_database_file, {:headers=>:first_row}) do |row|
      counties[row["state"]] ||= {}
      counties[row["state"]][row["county"].to_s.downcase] ||= []
      counties[row["state"]][row["county"].to_s.downcase] << row["zip"]      

      cities[row["state"]] ||= {}
      cities[row["state"]][row["primary_city"].to_s.downcase] ||= []
      cities[row["state"]][row["primary_city"].to_s.downcase] << row["zip"]      

    end
    return [counties, cities]
  end

  def self.zip5map
    @@zip5 ||= read_zip_file('zip5.csv')
  end

  def self.zip3map
    @@zip3 ||= read_zip_file('zip3.csv')
  end

  def self.for_zip_code(zip)
    self[ zip5map[zip[0,5]] || zip3map[zip[0,3]] ]
  end

  def self.valid_zip_code?(zip)
    !for_zip_code(zip).nil?
  end
  
  def self.states_with_online_registration
    RockyConf.states_with_online_registration
  end
  
  def get_localization(locale)
    localizations.find_or_initialize_by_locale(locale.to_s)
  end
  
  def state_customization
    @state_customization ||= StateCustomization.for(self)
  end 
  
  def online_reg_enabled?(locale, reg)
    GeoState.states_with_online_registration.include?(self.abbreviation) && self.enabled_for_language?(locale, reg)
  end
  
    
  
end
