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
    
    delegate :us_citizen?, :will_be_18_by_election?, 
      :first_name, :middle_name, :last_name,
      :prev_first_name, :prev_middle_name, :prev_last_name,
      :home_address, :home_unit, :home_city, :home_state_name, :home_zip,
      :mailing_address, :mailing_unit, :mailing_city, :mailing_state_name, :mailing_zip,
      :prev_address, :prev_unit, :prev_city, :prev_state_name, :prev_zip, 
      :to=>:registrant
    
    def initialize(r)
      @registrant = r
    end
    
    delegate :api_url, :api_key, :api_posting_entity_name, :to=>:api_settings
    
    def api_settings
      RockyConf.ovr_states.CA.api_settings
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
    
    def ethnicity_id
      case registrant.english_race
      when "A"
        1231230
      else
        2321230
      end
    end
    
    def get_binding
      binding
    end
    
  end
  
  
  XML_TOKEN_REGEXP = /\<Token\>(.+)\<\/Token\>/
  
  def has_ovr_pre_check?(registrant)
    true
  end
  
  def ovr_pre_check(registrant, controller)
    request_xml = self.class.build_soap_xml(registrant)
    api_response = self.class.request_token(request_xml)
    
    if RockyConf.ovr_states.CA.api_settings.debug_in_ui
      controller.render :xml=>api_response, :layout=>nil, :content_type=>"application/xml"
    else
      raise 'NOT HERE YET'
      # 4. Else, parse response
      # 5. if "success", mark as such
      # 6. Go to page 4 (which, for CA, may or may not include the "finish with state" option)
      
      token = self.class.extract_token_from_xml_response(api_response)
      if token.blank?
        
      else
      end
    end
  end
  
  def self.build_soap_xml(registrant)
    raise ERB.new(File.new(soap_xml_erb_file).read).result(RegistrantBinding.new(registrant).get_binding)
  end
  
  def self.soap_xml_erb_file
    Rails.root.join("app/models/state_customizations/ca/soap_request.xml.erb")
  end
  
  def self.extract_token_from_xml_response(xml_string)
    if xml_string =~ XML_TOKEN_REGEXP
      return $1
    else
      return nil
    end
  end
  
end