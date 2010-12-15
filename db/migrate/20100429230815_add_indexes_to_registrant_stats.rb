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
class AddIndexesToRegistrantStats < ActiveRecord::Migration
  def self.up
    add_index "registrants", "partner_id"
    add_index "registrants", "status"
    add_index "registrants", "name_title"
    add_index "registrants", "home_state_id"
    add_index "registrants", "race"
    add_index "registrants", "age"
    add_index "registrants", "created_at"
  end

  def self.down
    remove_index "registrants", "created_at"
    remove_index "registrants", "age"
    remove_index "registrants", "race"
    remove_index "registrants", "home_state_id"
    remove_index "registrants", "name_title"
    remove_index "registrants", "status"
    remove_index "registrants", "partner_id"
  end
end
