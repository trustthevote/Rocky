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
  
  delegate :online_reg_url, :redirect_to_online_reg_url, :has_ovr_pre_check?, :ovr_pre_check, :to=>:state_customization

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
  
  def online_reg_enabled?(locale)
    GeoState.states_with_online_registration.include?(self.abbreviation) && self.enabled_for_language?(locale)
  end
  
  def enabled_for_language?(lang)
    lang_list = RockyConf.ovr_states[self.abbreviation]
    return true if lang_list.blank?
    lang_list = lang_list["languages"]
    return true if lang_list.blank? || lang_list.empty?
    return lang_list.include?(lang)
  end
    
  
end
