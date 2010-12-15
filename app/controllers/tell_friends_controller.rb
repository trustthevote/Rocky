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
class TellFriendsController < RegistrationStep
  CURRENT_STEP = 7

  def create
    find_registrant(:tell_friend)
    @registrant.attributes = params[:tell_friend] if params[:tell_friend]
    @registrant.telling_friends = true
    @email_sent = @registrant.valid?
    # registrant sends email as side-effect of there being valid tell-friend params
    @root_url_escaped = CGI::escape(root_url)
    render "finishes/show"
  end

  protected

  def advance_to_next_step
    # noop
  end

  def next_url
    registrant_finish_url(@registrant)
  end
end
