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
  
  def self.state_online_reg_file_name
    "config/states_with_online_registration.yml"
  end
  
  def self.states_with_online_registration
    @@states_with_online_registration ||= nil
    if @@states_with_online_registration.nil?
      File.open(File.join(Rails.root, state_online_reg_file_name), "r") do |f|
        @@states_with_online_registration = YAML::load(f)
      end
    end
    @@states_with_online_registration
  end
  
  def online_reg_enabled?
    GeoState.states_with_online_registration.include?(self.abbreviation)
  end
  
  
  def online_reg_url(registrant)
    case self.name
      when "Arizona"
        "https://servicearizona.com/webapp/evoter/selectLanguage"
      when "California"
        "http://www.registertovote.ca.gov/"
      when "Colorado"
        "https://www.sos.state.co.us/Voter/secuVerifyExist.do"
      when "Washington"
        root_url ="https://weiapplets.sos.wa.gov/myvote/myvote"
        return root_url if registrant.nil?
        fn = CGI.escape registrant.first_name.to_s
        ln = CGI.escape registrant.last_name.to_s
        dob= CGI.escape registrant.form_date_of_birth.to_s.gsub('-','/')
        lang= registrant.locale
        "#{root_url}?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastName=#{ln}&DOB=#{dob}"
      when "Nevada"
        root_url ="https://nvsos.gov/sosvoterservices/Registration/step1.aspx?source=rtv&utm_source=rtv&utm_medium=rtv&utm_campaign=rtv"
        return root_url if registrant.nil?
        fn = CGI.escape registrant.first_name.to_s
        mn = CGI.escape registrant.middle_name.to_s
        ln = CGI.escape registrant.last_name.to_s
        sf = CGI.escape registrant.name_suffix.to_s
        zip = CGI.escape registrant.home_zip_code.to_s
        lang = registrant.locale.to_s
        "#{root_url}&fn=#{fn}&mn=#{mn}&ln=#{ln}&lang=#{lang}&zip=#{zip}&sf=#{sf}"
      else
        ""
    end
  end
  
  
  
end
