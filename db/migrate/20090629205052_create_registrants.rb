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
class CreateRegistrants < ActiveRecord::Migration
  def self.up
    create_table "registrants" do |t|
      t.string      "status"
      t.string      "locale", :limit => 2
      t.integer     "partner_id"
      t.string      "uid"
      t.integer     "reminders_left", :default => 0

      t.date        "date_of_birth"
      t.string      "email_address"
      t.boolean     "first_registration"
      t.string      "home_zip_code", :limit => 10
      t.boolean     "us_citizen"

      t.string      "name_title"
      t.string      "first_name"
      t.string      "middle_name"
      t.string      "last_name"
      t.string      "name_suffix"
      t.string      "home_address"
      t.string      "home_unit"
      t.string      "home_city"
      t.integer     "home_state_id"
      t.boolean     "has_mailing_address"
      t.string      "mailing_address"
      t.string      "mailing_unit"
      t.string      "mailing_city"
      t.integer     "mailing_state_id"
      t.string      "mailing_zip_code", :limit => 10
      t.string      "party"
      t.string      "race"

      t.string      "state_id_number"
      t.string      "phone"
      t.string      "phone_type"
      t.boolean     "change_of_name"
      t.string      "prev_name_title"
      t.string      "prev_first_name"
      t.string      "prev_middle_name"
      t.string      "prev_last_name"
      t.string      "prev_name_suffix"
      t.boolean     "change_of_address"
      t.string      "prev_address"
      t.string      "prev_unit"
      t.string      "prev_city"
      t.integer     "prev_state_id"
      t.string      "prev_zip_code", :limit => 10

      t.boolean     "opt_in_email"
      t.boolean     "opt_in_sms"

      t.string      "survey_answer_1"
      t.string      "survey_answer_2"

      t.boolean     "ineligible_non_participating_state"
      t.boolean     "ineligible_age"
      t.boolean     "ineligible_non_citizen"
      t.boolean     "ineligible_attest"

      t.timestamps
    end
    add_index "registrants", "uid"
  end

  def self.down
    drop_table "registrants"
  end
end
