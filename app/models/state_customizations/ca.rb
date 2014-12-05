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

class CA < StateCustomization
  class RegistrantBinding
    
    attr_reader :registrant
    
    delegate :email_address,
      :first_name, :middle_name, :last_name,
      :prev_first_name, :prev_middle_name, :prev_last_name,
      :home_address, :home_unit, :home_city, :home_state_name, :home_zip_code,
      :mailing_address, :mailing_unit, :mailing_city, :mailing_state_name, :mailing_zip_code,
      :prev_address, :prev_unit, :prev_city, :prev_state_name, :prev_zip_code, 
      :covr_token, :covr_success,
      :to=>:registrant
    
    def initialize(r)
      @registrant = r
    end
    
    def escape_xml(a_string)
      "#{CGI.escapeHTML(a_string.to_s)}"
    end
    
    def method_missing(meth, *args, &block)
      if meth =~ /^escape_xml_(.+)/
        self.escape_xml(self.send($1))
      else
        super
      end
    end
    
    delegate :api_url, :api_key, :api_posting_entity_name, :to=>:api_settings
    
    def api_settings
      RockyConf.ovr_states.CA.api_settings
    end
    
    def us_citizen?
      registrant.us_citizen? ? '1' : '0'
    end
    
    def will_be_18_by_election?
      registrant.will_be_18_by_election? ? '1' : '0'
    end
    
    def dob_day
      registrant.date_of_birth.day
    end
    def dob_month
      registrant.date_of_birth.month
    end
    def dob_year
      registrant.date_of_birth.year
    end
    
    def phone
      registrant.phone_digits
    end
    
    def has_home_address?
      1
    end
    
    def has_mailing_address?
      registrant.has_mailing_address ? '1' : '0'
    end
    
    def has_prev_address?
      registrant.change_of_address? ? '1' : '0'
    end
    
    
    
    # 1 Other
    # 2 American Indian or Alaska Native
    # 3 Asian or Pacific Islander
    # 4 Black, not of Hispanic Origin
    # 5 Hispanic
    # 6 Multi-racial
    # 7 White, not of Hispanic Origin
    def ethnicity_id
      case registrant.race_key.to_s
      when 'american_indian_alaskan_native'
        2
      when 'asian'
        3
      when 'black_not_hispanic'
        4
      when 'hispanic'
        5
      when 'mutli_racial'
        6
      when 'white_not_hispanic'
        7
      when 'other'
        1
      else
        ""
      end
    end
    
    # 2 English
    # 3 Chinese
    # 4 Vietnamese
    # 5 Korean
    # 6 Tagalog
    # 7 Japanese
    # 8 Hindi
    # 9 Khmer
    # 10 Thai
    # 11 Spanish
    def language_id
      case registrant.locale.to_s
      when 'en'
        2
      when 'zh', 'zh-tw'
        3
      when 'vi'
        4
      when 'ko'
        5
      when 'tl'
        6
      when 'ja'
        7
      when 'hi'
        8
      when 'km'
        9
      when 'th'
        10
      when 'es'
        11
      else
        ""
      end        
    end
    
    # English en-US
    # Chinese zh-CN
    # Vietnamese vi-VN
    # Korean ko-KR
    # Tagalog tl-PH
    # Japanese ja-JP
    # Hindi hi-IN
    # Khmer km-KH
    # Thai th-TH
    # Spanish es-MX
    
    def language_code
      case registrant.locale.to_s
      when 'en'
        "en-US"
      when 'zh', 'zh-tw'
        "zh-CN"
      when 'vi'
        "vi-VN"
      when 'ko'
        "ko-KR"
      when 'tl'
        "tl-PH"
      when 'ja'
        "ja-JP"
      when 'hi'
        "hi-IN"
      when 'km'
        "km-KH"
      when 'th'
        "th-TH"
      when 'es'
        "es-MX"
      else
        ""
      end
    end
    
    # 1 Mr.
    # 2 Mrs.
    # 3 Miss
    # 4 Ms.
    def name_prefix_id
      case registrant.name_title_key.to_s
      when 'mr'
        1
      when 'mrs'
        2
      when 'miss'
        3
      when 'ms'
        4
      else
        ""
      end
    end
    
    
    def get_binding
      binding
    end
    
  end
  
  
  XML_TOKEN_REGEXP = /\<Token\>(.+)\<\/Token\>/
  XML_ERROR_CODE_REGEXP = /\<ErrorCode\>(.+)\<\/ErrorCode\>/
  XML_ERROR_MESSAGE_REGEXP = /\<ErrorMessage\>(.+)\<\/ErrorMessage\>/
  
  
  # http://covrtest.sos.ca.gov/?
  #    language=en-US&
  #    t=p&
  #    CovrAgencyKey=RTV&
  #    PostingAgencyRecordId=BCE31E53-7E91-419Z-904Z-914352C45C34C570P
  def online_reg_url(registrant)
    base_url = RockyConf.ovr_states.CA.api_settings.web_url_base
    ak = RockyConf.ovr_states.CA.api_settings.web_agency_key
    if registrant.nil?
      "#{base_url}?language=LANGUAGE&t=p&CovrAgencyKey=AGENCY_KEY&PostingAgencyRecordId=TOKEN"
    else
      decorate_registrant(registrant)
      rb = RegistrantBinding.new(registrant)
      oru = "#{base_url}?language=#{rb.language_code}&t=p&CovrAgencyKey=#{ak}&PostingAgencyRecordId=#{rb.covr_token}"
      if self.class.log_requests?
        log_covr_info("Built URL #{oru} for registrant redirect")
      end
      oru
    end
  end
  
  
  def has_ovr_pre_check?(registrant)
    true
  end
  
  
  def decorate_registrant(registrant=nil, controller=nil)
    unless registrant.respond_to?(:covr_token)
      registrant.class.class_eval do
        state_attr_accessor :covr_token, :covr_success, :ca_disclosures
        validates_acceptance_of :ca_disclosures, :if=>:using_state_online_registration?, :message=> :ca_disclosures_error
        
        define_method(:disclosures_font_size) do
          fs = (RockyConf.ovr_states.CA.api_settings.disclosures_font_size || '12').to_s
          return (fs =~ /px$/) ? fs : "#{fs}px"
        end
        
        define_method(:disclosures_box_height) do
          fs = (RockyConf.ovr_states.CA.api_settings.disclosures_box_height || '170').to_s
          return (fs =~ /px$/) ? fs : "#{fs}px"
        end
      end
    end
    if registrant.ca_disclosures.nil? || registrant.ca_disclosures.blank?
      setting = RockyConf.ovr_states.CA.api_settings.disclosures_prechecked 
      if setting || setting.nil?
        registrant.ca_disclosures = true
      end
    end
  end
  
  
  def ovr_pre_check(registrant, controller)
    decorate_registrant(registrant, controller)
    request_xml = self.class.build_soap_xml(registrant)
    api_response = self.class.request_token(request_xml)
    
    if RockyConf.ovr_states.CA.api_settings.debug_in_ui
      controller.debug_data[:api_xml_response] = api_response
      controller.debug_data[:api_xml_request] = request_xml
      #controller.render :xml=>api_response, :layout=>nil, :content_type=>"application/xml"
    end

    covr_token = self.class.extract_token_from_xml_response(api_response)
    if covr_token
      registrant.covr_token = covr_token
      registrant.covr_success = true
    else
      error_code = self.class.extract_error_code_from_xml_response(api_response)
      error_message = self.class.extract_error_message_from_xml_response(api_response)
      log_covr_error("Error #{error_code}: #{error_message.strip}")
    end
  end
    
  NUM_DISCLOSURES = 5
  
  def enabled_for_language?(lang, reg)
    if CA.disclosures.nil? || CA.disclosures[lang.to_s].nil? || CA.disclosures[lang.to_s].size != NUM_DISCLOSURES
      return false
    end
    return true if ovr_settings.blank?
    lang_list = ovr_settings["languages"]
    return true if lang_list.blank? || lang_list.empty?
    return lang_list.include?(lang)
    
  end
  
  def self.disclosures
    @@disclosures ||= nil
    if @@disclosures.nil?
      self.load_disclosures
    end
    @@disclosures
  end
  
  def self.load_disclosures
    @@disclosures = {}
    
    RockyConf.ovr_states.CA.languages.each do |locale|
      @@disclosures[locale.to_s] ||= {}
      NUM_DISCLOSURES.times do |i|
        num = i+1
        begin
          @@disclosures[locale.to_s][num] = RestClient.get(disclosure_url(locale, num)).to_s.force_encoding('UTF-8')
        rescue Exception=>e
          log_covr_error("While loading disclosures from #{disclosure_url(locale, num)} - #{e.message}\n#{e.backtrace.join("\n\t")}")
        end
      end
    end
  end
  def self.disclosure_url(lang, num)
    base = RockyConf.ovr_states.CA.api_settings.disclosures_url
    base = "#{base}/" unless (base =~ /\/$/)
    lang_used = lang == "zh-tw" ? "zh" : lang
    "#{base}#{lang_used}/discl#{num}.txt"
  end
  
  def self.build_soap_xml(registrant)
    ERB.new(File.new(soap_xml_erb_file).read).result(RegistrantBinding.new(registrant).get_binding)
  end
  
  def self.soap_xml_erb_file
    Rails.root.join("app/models/state_customizations/ca/soap_request.xml.erb")
  end
  
  def self.request_token(request_xml)
    if log_requests?
      log_covr_info("COVR:: Making Request to: #{RockyConf.ovr_states.CA.api_settings.api_url}")
      log_covr_info("With XML\n#{request_xml}\n")
    end
    begin
      resp = Integrations::Soap.make_request(RockyConf.ovr_states.CA.api_settings.api_url, request_xml)
      if log_requests?
        log_covr_info("COVR:: Response:\n#{resp}\n")
      end
      return resp
    rescue Exception => e
      if log_requests?
        log_covr_error("#{e.message}\n#{e.backtrace.join("\n\t")}")
      end
      nil
    end
  end
  
  def self.log_requests?
    RockyConf.ovr_states.CA.api_settings.log_all_requests
  end
  
  def self.extract_token_from_xml_response(xml_string)
    if xml_string.to_s =~ XML_TOKEN_REGEXP
      return $1
    else
      return nil
    end
  end

  def self.extract_error_code_from_xml_response(xml_string)
    if xml_string =~ XML_ERROR_CODE_REGEXP
      return $1
    else
      return "N/A"
    end
  end

  def self.extract_error_message_from_xml_response(xml_string)
    if xml_string =~ XML_ERROR_MESSAGE_REGEXP
      return $1.strip
    else
      return "Error Message Not Found"
    end
  end
  
  
  def log_covr_info(message)
    self.class.log_covr_info(message)
  end
  
  def self.log_covr_info(message)
    Rails.logger.info("COVR:: #{message}")
  end

  def log_covr_error(message)
    self.class.log_covr_error(message)
  end
  
  def self.log_covr_error(message)
    Rails.logger.warn("COVR:: #{RockyConf.ovr_states.CA.api_settings.custom_error_string}\n#{message}")
  end

  
end