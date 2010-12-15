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
class CreateGeoStates < ActiveRecord::Migration
  def self.up
    create_table "geo_states" do |t|
      t.string "name", :limit => 21
      t.string "abbreviation", :limit => 2
      t.boolean "requires_race"
      t.boolean "requires_party"
      t.boolean "participating"
      t.integer "id_length_min"
      t.integer "id_length_max"
      t.string "registrar_address"
      t.string "registrar_phone"
      t.timestamps
    end

    create_table "state_localizations" do |t|
      t.integer "state_id"
      t.string "locale", :limit => 2
      t.string "parties"
      t.string "no_party"
      t.string "not_participating_tooltip", :limit => 1024
      t.string "race_tooltip", :limit => 1024
      t.string "id_number_tooltip", :limit => 1024
      t.timestamps
    end
  end

  def self.down
    drop_table "state_localizations"
    drop_table "geo_states"
  end
end
