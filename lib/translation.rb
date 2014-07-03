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
class Translation
  
  def self.var_expression
    /(\%\{[^\{]+\})/
  end
  def var_expression
    self.class.var_expression
  end
  
  def self.base_directory
    Rails.root.join('config','locales')
  end
  
  def self.type_names
    ['core', 'states', 'txt', 'email', 'pdf']
  end
  
  def self.types
    type_names.collect{|t| Translation.new(t) }
  end
  
  def self.directories
     types.collect{|t| directory(t) }
  end
  
  def self.file_names
    I18n.available_locales.collect{|l| "#{l}.yml"}
  end
  
  def self.find(type)
    self.new(type)
  end
  
  def self.directory(type)
    type == 'core' ? base_directory : base_directory.join(type)
  end
  
  def self.instructions_for(key)
    instructions = []
    en_value = I18n.t(key, :locale=>'en')
    en_value.to_s.scan(var_expression).each do |match|
      instructions << "Please keep '#{match.first}' intact"
    end
    specific_instructions = I18n.t("#{key}_translation_instructions", :locale=>'en', :default=>'')
    instructions << specific_instructions unless specific_instructions.blank?

    instructions
  end
  
  def self.language_name(locale)
    I18n.t('language_name', :locale=>locale) + " (#{locale})"
  end
  
  def self.css_path(locale)
    css_dir.join("#{locale}.css.scss").to_s
  end
  
  def self.nvra_css_path(locale)
    nvra_css_dir.join("#{locale}.css.scss").to_s
  end
  
  def self.has_css?(locale)
    File.exists?(css_path(locale))
  end
  
  def self.has_nvra_css?(locale)
    File.exists?(nvra_css_path(locale))
  end
  
  def self.css_dir
    Rails.root.join("app/assets/stylesheets/locales")
  end
  
  def self.nvra_css_dir
    Rails.root.join("app/assets/stylesheets/nvra/locales")
  end
  
  def self.tmp_file_dir
    dir = Rails.root.join('tmp', 'translation_files')
    FileUtils.mkdir_p(dir)
    return dir
  end
  
  def self.tmp_file_path(type, locale)
    tmp_file_dir.join("#{type}-#{locale}.yml")
  end
  
  
  attr_reader :directory
  attr_reader :type
  attr_reader :errors
  
  def initialize(type)
    raise "Not Found" if !self.class.type_names.include?(type)
    @type = type
    @directory = self.class.directory(type)
    @errors = {:blanks=>[], :missing_variables=>[]}
  end
  
  def tmp_file_path(type, locale)
    self.class.tmp_file_path(type, locale)
  end
  
  
  def blanks
    errors[:blanks]
  end
  def blanks=(val)
    errors[:blanks]=val
  end
  
  def missing_variables
    errors[:missing_variables]
  end
  def missing_variables=(val)
    errors[:missing_variables]=val
  end
  
  def name
    @type.capitalize
  end
  
  def is_email?
    self.type.to_s == 'email'
  end
  
  def to_param
    @type
  end
  
  def file_path(fn)
    temp_file = tmp_file_path(type, language(fn))
    if File.exists?(temp_file)
      temp_file
    else 
      File.join(directory, fn)
    end
  end
  
  def language(fn)
    fn.gsub(".yml", '')
  end
  
  def contents
    @contents ||= {}
    if @contents.empty?
      self.class.file_names.each do |fn|
        File.open(file_path(fn)) do |file|
          h = YAML.load(file)
          @contents[language(fn)] = h[h.keys.first] || {}
        end
      end
    end
    @contents
  end
  
  def get_from_contents(key, locale, group=nil)
    hash_keys = key.split('.')
    group ||= contents[locale]
    if hash_keys.size == 1
      return group[hash_keys.first]
    else
      group = group[hash_keys.shift]
      
      get_from_contents(hash_keys.join('.'), locale, group)
    end
  end
  
  def is_blank?(key)
    blanks.include?(key)
  end
  
  def is_missing_variable?(key)
    missing_variables.include?(key)
  end
  
  def has_error?(key)
    is_blank?(key) || is_missing_variable?(key)
  end
  
  def has_errors?
    !blanks.empty? || !missing_variables.empty?
  end
  
  
  def generate_yml(locale, key_values)
    keys_hash, @errors = self.class.hash_from_form(key_values, true, self.blanks, self.missing_variables)
    full_hash = {locale=>keys_hash}
    contents #load it
    @contents[locale] = full_hash[locale]
    full_hash.to_yaml
  end
  
  def self.hash_from_form(key_values, check_translations=false, blanks=[], missing_variables=[])
    starter_hash={}
    
    key_values.each do |k,v|
      last_hash = starter_hash
      key_chain = k.split('.')
      key_chain.each_with_index do |key, i|
        if (i+1 == key_chain.size)
          last_hash[key] = value_for_yml(v)
          if check_translations
            if value_is_blank(v, k)
              blanks << k
            end
            if value_is_missing_variable(v, k)
              missing_variables << k
            end
          end
        else
          last_hash[key] ||= {}
          last_hash = last_hash[key]
        end
      end
    end
    return [starter_hash, {:blanks=>blanks, :missing_variables=>missing_variables}]
  end
  
  def self.value_for_yml(v)
    val = v.is_a?(String) ? v.gsub(/\r\n/,"\n") : v
    if val.is_a?(String)
      if val.strip.downcase == "true"
        val = true
      elsif val.strip.downcase == "false"
        val = false
      end
    end
    return val
  end
  
  def value_is_blank(k,v)
    return self.class.value_is_blank(k,v)
  end
  def self.value_is_blank(v, k)
     return true if v.blank? && !I18n.t(k, :locale=>:en).blank? 
     if v.is_a?(Array)
       new_vals = v.collect{|item| item.blank? ? nil : item }.compact
       old_vals = I18n.t(k, {:locale=>:en})
       if old_vals.is_a?(Array)
         old_vals = old_vals.collect{|item| item.blank? ? nil : item }.compact
         return true if new_vals.size != old_vals.size
       end
     end
     return false
  end
  
  def value_is_missing_variable(v, k)
    return self.class.value_is_missing_variable(v, k)
  end
  def self.value_is_missing_variable(v, k)
    en_value = I18n.t(k, :locale=>:en)
    if en_value =~ var_expression && !(v =~ var_expression)
      return true
    end
    return false    
  end
  
end