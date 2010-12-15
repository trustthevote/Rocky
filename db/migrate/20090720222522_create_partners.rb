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
class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table "partners" do |t|
      t.string    "username",           :null => false
      t.string    "email",              :null => false
      t.string    "crypted_password",   :null => false
      t.string    "password_salt",      :null => false
      t.string    "persistence_token",  :null => false
      t.string    "perishable_token",   :default => "", :null => false
      t.string    "name"
      t.string    "organization"
      t.string    "url"
      t.string    "address"
      t.string    "city"
      t.integer   "state_id"
      t.string    "zip_code", :limit => 10
      t.string    "phone"
      t.string    "logo_image_url"
      t.string    "survey_question_1_en"
      t.string    "survey_question_1_es"
      t.string    "survey_question_2_en"
      t.string    "survey_question_2_es"
      t.timestamps
    end
    add_index "partners", "username"
    add_index "partners", "email"
    add_index "partners", "persistence_token"
    add_index "partners", "perishable_token"
  end

  def self.down
    drop_table "partners"
  end
end
