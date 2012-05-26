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
require File.dirname(__FILE__) + '/../spec_helper'

describe StateImporter do
  attr_accessor :csv_basic, :file_basic
  before(:each) do
    @csv_basic = <<CSV
abbreviation,name,participating,not_participating_tooltip_en,not_participating_tooltip_es,requires_race,party_tooltip_en,party_tooltip_es,race_tooltip_en,race_tooltip_es,requires_party,parties_en,parties_es,no_party_en,no_party_es,id_length_min,id_length_max,id_number_tooltip_en,id_number_tooltip_es,sos_address,sos_phone,sos_url,sub_18_en,sub_18_es
AL,Alabama,1,dead_end_en,dead_end_es,1,party_tooltip_en,party_tooltip_es,race_tooltip_en,race_tooltip_es,1,"Red, Green, Blue","Rojo, Verde, Azul",no_party_en,no_party_es,8,12,id_number_tooltip_en,id_number_tooltip_es,sos_address,sos_phone,sos_url,sub_18_en,sub_18_es
AK,Alaska,0,dead_end_en,dead_end_es,1,party_tooltip_en,party_tooltip_es,race_tooltip_en,race_tooltip_es,1,"Red, Green, Blue","Rojo, Verde, Azul",no_party_en,no_party_es,10,13,id_number_tooltip_en,id_number_tooltip_es,sos_address,sos_phone,sos_url,sub_18_en,sub_18_es
AZ,Arizona,1,dead_end_en,dead_end_es,0,party_tooltip_en,party_tooltip_es,race_tooltip_en,race_tooltip_es,0,,,,,8,12,id_number_tooltip_en,id_number_tooltip_es,sos_address,sos_phone,sos_url,sub_18_en,sub_18_es
CSV
    @file_basic = StringIO.new(@csv_basic)
  end

  describe "populate GeoState" do
    before(:each) do
      GeoState.reset_all_states
    end
    it "sets fields in state record" do
      silence_output do
        StateImporter.import(file_basic)
      end

      state = GeoState['AL']
      assert_equal true, state.participating
      assert_equal true, state.requires_race
      assert_equal true, state.requires_party
      assert_equal 8, state.id_length_min
      assert_equal 12, state.id_length_max
      assert_equal "sos_address", state.registrar_address
      assert_equal "sos_phone", state.registrar_phone
      assert_equal "sos_url", state.registrar_url

      state = GeoState['AK']
      assert_equal false, state.participating
      assert_equal 10, state.id_length_min
      assert_equal 13, state.id_length_max

      state = GeoState['AZ']
      assert_equal true, state.participating
      assert_equal false, state.requires_race
      assert_equal false, state.requires_party
      assert_equal 8, state.id_length_min
      assert_equal 12, state.id_length_max
    end

    it "updates existing state with new values" do
      alabama = GeoState['AL']
      alabama.update_attributes!(:name => "ALABAMA")
      silence_output do
        StateImporter.import(file_basic)
      end
      alabama.reload
      assert_equal "Alabama", alabama.name
    end
  end

  describe "populate state localizations" do
    before(:each) do
      GeoState.reset_all_states
      StateLocalization.destroy_all
    end

    it "sets fields in each locale's record" do
      silence_output do
        StateImporter.import(file_basic)
      end

      state = GeoState['AL']
      en = state.localizations.find_by_locale!('en')
      assert_equal "dead_end_en", en.not_participating_tooltip
      assert_equal "race_tooltip_en", en.race_tooltip
      assert_equal %w(Red Green Blue), en.parties
      assert_equal "no_party_en", en.no_party
      assert_equal "id_number_tooltip_en", en.id_number_tooltip
      assert_equal "sub_18_en", en.sub_18
      es = state.localizations.find_by_locale!('es')
      assert_equal "dead_end_es", es.not_participating_tooltip
      assert_equal "race_tooltip_es", es.race_tooltip
      assert_equal %w(Rojo Verde Azul), es.parties
      assert_equal "no_party_es", es.no_party
      assert_equal "id_number_tooltip_es", es.id_number_tooltip
      assert_equal "sub_18_es", es.sub_18

      state = GeoState['AZ']
      en = state.localizations.find_by_locale!('en')
      assert_equal [], en.parties
    end

    it "checks sanity of actual states.csv file" do
      headers = File.open(Rails.root.join("db/bootstrap/import/states.csv")) do |csv_file|
        csv_file.gets.chomp.split(",").sort
      end.map { |h| h.gsub('"', '') }

      assert_equal @csv_basic.split("\n").first.split(",").sort, headers
    end
  end

  describe "reports errors" do
    attr_accessor :csv_bad, :file_bad
    before(:each) do
      @csv_bad = <<CSV
abbreviation,name
A,Aa
B,Bb
C,Cc
CSV
      @file_bad = StringIO.new(@csv_bad)
    end
    it "catches errors to report them" do
      old_stderr = $stderr
      err_output = StringIO.new('')
      $stderr = err_output
      assert_nothing_raised do
        silence_output do
          StateImporter.import(file_bad)
        end
      end
      $stderr = old_stderr
      assert_match /could not import state data/, err_output.string
    end
  end

  def silence_output
    old_stdout = $stdout
    $stdout = StringIO.new('')
    yield
  ensure
    $stdout = old_stdout
  end
end
