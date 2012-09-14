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
class StateOnlineRegistrationsController < RegistrationStep

protected
  
  def set_up_view_variables
    set_up_share_variables
    
    
    @online_registration_iframe_url = case @registrant.home_state_name
    when "Arizona"
      "https://servicearizona.com/webapp/evoter/selectLanguage"
    when "California"
      "https://www.sos.ca.gov/elections/register-to-vote/"
    when "Colorado"
      "https://www.sos.state.co.us/Voter/secuVerifyExist.do"
    when "Washington"
      fn = CGI.escape @registrant.first_name.to_s
      ln = CGI.escape @registrant.last_name.to_s
      dob= CGI.escape @registrant.form_date_of_birth.to_s.gsub('-','/')
      lang= @registrant.locale
      "https://weiapplets.sos.wa.gov/myvote/myvote?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastName=#{ln}&DOB=#{dob}"
    when "Nevada"
      fn = CGI.escape @registrant.first_name.to_s
      mn = CGI.escape @registrant.middle_name.to_s
      ln = CGI.escape @registrant.last_name.to_s
      sf = CGI.escape @registrant.name_suffix.to_s
      zip = CGI.escape @registrant.home_zip_code.to_s
      lang = @registrant.locale.to_s
      "https://nvsos.gov/sosvoterservices/Registration/step1.aspx?source=rtv&fn=#{fn}&mn=#{mn}&ln=#{ln}&lang=#{lang}&zip=#{zip}&sf=#{sf}"
    else
      ""
    end    
  end
  
  def find_registrant
    super
    @registrant.update_attributes(:finish_with_state=>true)
  end
  
end
