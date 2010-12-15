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
class Step2Controller < RegistrationStep
  CURRENT_STEP = 2

  def update
    if params[:javascript_disabled] == "1" && params[:registrant]
      reg = params[:registrant]
      if reg[:has_mailing_address] == "0"
        reg[:has_mailing_address] = !"#{reg[:mailing_address]}#{reg[:mailing_unit]}#{reg[:mailing_city]}#{reg[:mailing_zip_code]}".blank?
      end
    end
    super
  end

  protected
  
  def advance_to_next_step
    @registrant.advance_to_step_2
  end

  def next_url
    registrant_step_3_url(@registrant)
  end

  def set_up_view_variables
    @registrant.mailing_state ||= @registrant.home_state
    @state_parties = @registrant.state_parties
    @race_tooltip = @registrant.race_tooltip
    @party_tooltip = @registrant.party_tooltip
  end
end
