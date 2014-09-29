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
class StateImporter
  
  attr_accessor :file, :defaults, :states_hash
  
  def self.defaults
    @@defaults ||= StateImporter.new.defaults
  end
  
  # conf_keys with values that are not I18n key-parts
  def self.state_settings
    # [method_name, yaml_key]
    unaliased = %w(name participating requires_race requires_party id_length_min id_length_max online_registration_url)
    unaliased.collect{|m| [m, m]} +
    [['registrar_address','sos_address'],
     ['registrar_phone','sos_phone'],
     ['registrar_url','sos_url']]
  end

  #list of conf_keys with values that are I18n key-parts
  def self.state_localizations
    %w(not_participating_tooltip race_tooltip party_tooltip no_party id_number_tooltip sub_18 registration_deadline pdf_instructions email_instructions)
  end
  
  #list of conf_keys with values that are arrays
  def self.state_localization_lists
    %w(parties)
  end
  
  def self.tmp_file_dir
    dir = Rails.root.join('tmp', 'translation_files')
    FileUtils.mkdir_p(dir)
    return dir
  end
  
  def self.tmp_file_path
    tmp_file_dir.join("new-states.yml")
  end
  
  def self.file_path
    temp_file = tmp_file_path
    if File.exists?(temp_file)
      temp_file.to_s
    else 
      Rails.root.join('db/bootstrap/import/states.yml').to_s
    end
  end
  
  
  #< Initialization (fold)
  def initialize(file_or_filename = nil)
    @imported_states = []
    @imported_locales = []
    @imported_zip_addresses = []
    @messages = []
    @defaults = {}
    
    file_name = file_or_filename || self.class.file_path
    
    begin
      @file = initialize_file(file_name)
      @states_hash = YAML.load(@file)
      set_defaults(@states_hash)
      @file.close
    rescue
    end
  end
  
  private
  
  def initialize_file(file_name)
    file = nil
    if !file_name.is_a?(String)
      file = file_name
    else
      file = File.open(file_name)
    end
    return file
  end
  
  def set_defaults(states_hash)
    @defaults = states_hash[defaults_key] || {}
  end
  
  def defaults_key
    'defaults'
  end
  public
  #> Initialization (end)
  
  #< Reporting (fold)
  attr_accessor :messages
  def puts_report
    puts self.messages.join("\n\n")
  end
  
  protected
  def report_any_changes(old_obj, new_obj, message)
    if clean_for_changes(old_obj) != clean_for_changes(new_obj)
      full_string = "#{message}"
      full_string += "\n\tchange:\n\t> #{old_obj.to_s}\n\t> "
      full_string.force_encoding 'utf-8'
      full_string += "#{new_obj.to_s}"
      report(full_string)
    end
  end
  def clean_for_changes(obj)
    obj.to_s.gsub(/\s/,'')
  end
  def report(msg)
    self.messages << msg
  end
  public
  #> Reporting (end)

  #< Import (fold)
  attr_accessor :imported_states, :imported_locales, :imported_zip_addresses
  def import
    states_hash.each do |key, row|
      unless key == defaults_key
        begin
          print "#{row['name']}... "
          import_state(row)
          puts "DONE!"
        rescue StandardError => e
          $stderr.puts "!!! could not import state data for #{row['name']}"
          $stderr.puts e.message
          $stderr.puts e.backtrace
        end
      end
    end
    import_zip_county_addresses    
  end
  
  def import_zip_county_addresses
    GeoState.county_registrar_addresses.each do |state_abbr, counties|
      counties.each do |county, addr_zips|
        addr_zips[1].each do |zip|
          self.imported_zip_addresses << ZipCodeCountyAddress.new({
            :geo_state_id=> GeoState[state_abbr].id,
            :zip => zip,
            :address=>addr_zips[0],
            :county=>county
          })
        end
      end
    end
  end
  
  def commit!
    GeoState.transaction do
      imported_states.each do |state|
        state.save!
      end
      imported_locales.each do |loc|
        loc.save!
      end
      imported_zip_addresses.each do |zca|
        zca.save!
      end
    end
  end
  
  protected
  
  def import_state(row)
    state = GeoState[row["abbreviation"]]
    self.class.state_settings.each do |method, yaml_key|
      new_value = self.get_from_row(row, yaml_key)
      report_any_changes(state.send(method), new_value, "in #{state.name}.#{method}:")
      state.send("#{method}=", new_value)
    end
    self.imported_states <<  state
    import_localizations(state, row)
  end
  
  def import_localizations(state, row)
    I18n.available_locales.each do |locale|
      loc = state.get_localization(locale)

      self.class.state_localization_lists.each do |method|
        new_val = get_from_row(row, method).collect {|item| translate_list_item(method, item, locale, state.name)}
        report_any_changes(loc.send(method), new_val, "in #{state.name} local #{loc.id} #{method} list:")
        loc.send("#{method}=", new_val)        
      end
            
      self.class.state_localizations.each do |method|
        new_val = translate_from_row(row, method, locale, state.name)
        report_any_changes(loc.send(method), new_val, "in #{state.name} local #{loc.id} #{method}")
        loc.send("#{method}=", new_val)
      end
      
      self.imported_locales << loc
    end
  end
  
  def get_from_row(row, key)
    row[key].nil? ? self.defaults[key] : row[key]
  end
  
  def translate_from_row(row, key, locale, state_name='')
    key_value = get_from_row(row, key)
    self.class.translate_key(key_value, key, locale, state_name)
  end
  def translate_list_item(list_key, item_key, locale, state_name='')
    self.class.translate_list_item(list_key, item_key, locale, state_name)
  end
  
  
  public
  #> Import (end) 
  
  

  
  # def self.state_uses_default?(state, method, key=nil)
  #   self.defaults[key || method].to_s == state.send(method).to_s
  # end
  
  
  
  
  #< Config UI helpers (fold)
  def self.config_options(key)
    last_hash = translations_hash[:en].dup
    
    get_loc_part_array(key).each do |key_part|
      last_hash = last_hash[key_part.to_sym]
    end
    new_hash = {}
    last_hash.each do |k,v|
      new_hash[k] = {}
      I18n.available_locales.each do |lang|
        new_hash[k][lang] = translate_key(k, key, lang)
      end
    end
    new_hash
  end
  
  def self.translations_hash
    @@translations_hash ||= nil
    return @@translations_hash unless @@translations_hash.nil? || @@translations_hash[:en].nil?
    @@translations_hash = {}
    I18n.t('language_name') # Force initialize
    I18n.available_locales.each do |lang|
      @@translations_hash[lang] = I18n.backend.send(:translations)[lang]
    end
    @@translations_hash
  end
  
  
  
  
  def self.is_localization?(key)
    state_localizations.include?(key)
  end
  
  def self.is_localization_list?(key)
    state_localization_lists.include?(key)
  end
  
  
  def has_errors?
    false
  end
  
  def generate_yml(params)
    hash, errors = Translation.hash_from_form(params)
    remove_defaults(hash)
    hash.to_yaml
  end
  
  protected
  def remove_defaults(hash)
    hash.each do |k,v|
      if v.is_a?(Hash)
        remove_defaults(v)
      elsif v.is_a?(String)
        if v == "DEFAULT"
          hash.delete(k)
        end
      elsif v.is_a?(Array)
        if v.include?("DEFAULT")
          hash.delete(k)
        end
      end
    end
  end
  public
  #> Config UI helpers (end)
  
  
  
  #< Translation look-up (fold)
  def self.translate_key(key_value, key, locale, state_name='')
    loc_key = "#{get_loc_part(key)}.#{key_value}"
    I18n.t(loc_key, :locale=>locale, :state_name=>state_name).to_s.html_safe.strip  
  end
  
  def self.translate_list_item(list_key, item_key, locale, state_name='')
    I18n.t("states.#{list_key}.#{item_key}", 
      :locale=>locale, 
      :state_name=>state_name).to_s.html_safe.strip
  end
  
  def self.get_loc_part(key)
    get_loc_part_array(key).join('.')
  end
  
  def self.get_loc_part_array(key)
    parts = ["states"]
    if key =~ /tooltip/
      parts << "tooltips"
      parts << key.gsub('_tooltip', '')
    elsif key == 'no_party'
      parts << "no_party_label"
    else
      parts << key
    end
    parts
  end
  #> Translation look-up (end)
  
  
protected

  # 
  # 
  # 
  # def read_parties(raw)
  #   raw ? raw.split(',').collect {|s| s.strip} : []
  # end
  # 
  
  
  
  
end
