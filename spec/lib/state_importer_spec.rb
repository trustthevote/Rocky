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
require File.dirname(__FILE__) + '/../rails_helper'

describe StateImporter do
  attr_accessor :csv_basic, :file_basic
  before(:each) do
    
    GeoState.reset_county_zip_codes
    GeoState.reset_county_registrar_addresses

    GeoState.stub(:county_addresses_file).and_return(
      Rails.root.join("spec/fixtures/files/county_addressing/county_addresses.csv")
    )
    GeoState.stub(:zip_code_database_file).and_return(
      Rails.root.join("spec/fixtures/files/county_addressing/zip_code_database.csv")
    )

    @yml_basic = <<YML
    defaults:
      participating: true
      not_participating_tooltip: blank
      requires_race: false
      race_tooltip: virginia
      parties:
        - democratic
        - independent
        - green
        - libertarian
        - republican
        - other
      no_party: none
      id_length_min: '6'
      id_length_max: '60'
      sub_18: turn_by_next_election
      registration_deadline: postmarked_29_days
      pdf_instructions: blank
      email_instructions: blank
    record_0: 
      abbreviation: AL
      name: Alabama
      participating: "1"
      not_participating_tooltip: new_hampshire 
      requires_race: "1"
      requires_party: "1"
      parties:
        - independent
        - green
      id_length_min: "8"
      id_length_max: "12"
      sos_address: sos_address
      sos_phone: sos_phone
      sos_url: sos_url
      registration_deadline: postmarked_30_days
      email_instructions: alabama
    record_1: 
      abbreviation: AK
      name: Alaska
      participating: "0"
      requires_race: "1"
      requires_party: "1"
      id_length_min: "10"
      id_length_max: "13"
      sos_address: sos_address
      sos_phone: sos_phone
      sos_url: sos_url
      pdf_instructions: arkansas
    record_2: 
      abbreviation: AZ
      name: Arizona
      participating: "1"
      requires_race: "0"
      requires_party: "0"
      id_length_min: "8"
      id_length_max: "12"
      sos_address: sos_address
      sos_phone: sos_phone
      sos_url: sos_url
YML
    @file_basic = StringIO.new(@yml_basic)
  end

  describe "populate GeoState" do
    before(:each) do
      GeoState.reset_all_states
    end
    it "sets fields in state record" do
      silence_output do
        si = StateImporter.new(file_basic)
        si.import
        si.commit!
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
        si = StateImporter.new(file_basic)
        si.import
        si.commit!
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
        si = StateImporter.new(file_basic)
        si.import
        si.commit!
      end
      

      state = GeoState['AL']
      en = state.localizations.find_by_locale!('en')
      assert_equal I18n.t('states.tooltips.not_participating.new_hampshire').strip, en.not_participating_tooltip
      assert_equal I18n.t('states.tooltips.race.virginia').strip, en.race_tooltip
      assert_equal %w(Independent Green), en.parties
      assert_equal I18n.t('states.registration_deadline.postmarked_30_days'), en.registration_deadline
      assert_equal I18n.t('states.pdf_instructions.blank'), en.pdf_instructions
      assert_equal I18n.t('states.email_instructions.alabama'), en.email_instructions
      
      es = state.localizations.find_by_locale!('es')
      assert_equal I18n.t('states.tooltips.not_participating.new_hampshire', :locale=>:es).strip, es.not_participating_tooltip
      assert_equal I18n.t('states.tooltips.race.virginia', :locale=>:es).strip, es.race_tooltip
      assert_equal %w(Independiente Verde), es.parties
      assert_equal I18n.t('states.registration_deadline.postmarked_30_days', :locale=>:es), es.registration_deadline
      assert_equal I18n.t('states.pdf_instructions.blank', :locale=>:es), es.pdf_instructions
      assert_equal I18n.t('states.email_instructions.alabama', :locale=>:es), es.email_instructions
      
      state = GeoState['AK']
      en = state.localizations.find_by_locale!('en')
      assert_equal I18n.t('states.registration_deadline.postmarked_29_days'), en.registration_deadline
      assert_equal I18n.t('states.pdf_instructions.arkansas'), en.pdf_instructions
      assert_equal I18n.t('states.email_instructions.blank'), en.email_instructions
      

    end

  end

  describe "reports errors" do
    attr_accessor :csv_bad, :file_bad
    before(:each) do
      @yml_bad = <<YML
one:
  abbreviation: a
  name: Aa
two:
  abbreviation: b
  name: Bb
three:
  abbreviation: c
  name: Cc
YML
      @file_bad = StringIO.new(@yml_bad)
    end
    it "catches errors to report them" do
      old_stderr = $stderr
      err_output = StringIO.new('')
      $stderr = err_output
      assert_nothing_raised do
        silence_output do
          si = StateImporter.new(file_bad)
          si.import
          si.commit!
        end
        
      end
      $stderr = old_stderr
      assert_match /could not import state data/, err_output.string
    end
  end


  describe ".new" do
    context "without parameters passed" do
      let(:fs) { double(File) }
      let(:states_hash) { {'defaults'=>"defaults"} }
      before(:each) do
        File.stub(:open).and_return(fs)
        YAML.stub(:load).with(fs).and_return(states_hash)
        fs.stub(:close).and_return(true)
      end

      it "opens the db/bootstrap/import/states yml file" do
        File.should_receive(:open).with(Rails.root.join('db/bootstrap/import/states.yml').to_s).and_return(fs)
        si = StateImporter.new        
      end
      
      it "sets the states hash" do
        si = StateImporter.new
        si.states_hash.should == states_hash
      end
      
      it "reads defaults from states hash" do
        si = StateImporter.new
        si.defaults.should == "defaults"
        
      end
    
    end
    context "when passed a string" do
      
    end
    context "when passed a file" do
      let(:file) { double(File) }
      
    end
  end

  describe ".defaults" do
    it "returns defaults from a new instance" do
      si = double(StateImporter)
      si.should_receive(:defaults).and_return("base-defaults")
      StateImporter.should_receive(:new).and_return(si)
      StateImporter.defaults.should == "base-defaults"
    end
  end

  context "import" do
    let(:states_hash) do
      {
        record_0: {
          abbreviation: "AL",
          name: "Alabama",
          participating: "1",
          not_participating_tooltip: "new_hampshire",
          requires_race: "1",
          requires_party: "1",
          parties:
            ["independent",
            "green"],
          id_length_min: "8",
          id_length_max: "12",
          sos_address: "sos_address",
          sos_phone: "sos_phone",
          sos_url: "sos_url" },
        record_1: {
          abbreviation: "AK",
          name: "Alaska",
          participating: "0",
          requires_race: "1",
          requires_party: "1",
          id_length_min: "10",
          id_length_max: "13",
          sos_address: "sos_address",
          sos_phone: "sos_phone",
          sos_url: "sos_url" }
      }
    end
    let(:si) { StateImporter.new }
    before(:each) do
      si.stub(:states_hash).and_return(states_hash)
    end
    
    describe "#import" do
      it "runs import_state for each row in the hash" do
        si.should_receive(:import_state).with(states_hash[:record_0])
        si.should_receive(:import_state).with(states_hash[:record_1])
        si.should_receive(:import_zip_county_addresses)
        si.import
      end
      it "doesn't run :import_zip_county_addresses when skip_zip_county_import is true" do
        si.skip_zip_county_import = true
        si.should_not_receive(:import_zip_county_addresses)
        si.import
      end
      
    end
    describe "#import_state(row)" do
      let(:state) { double(GeoState).as_null_object }
      before(:each) do
        @row = states_hash[:record_0].stringify_keys
        si.stub(:import_localizations)
      end
      it "finds the state from the row" do
        GeoState.should_receive('[]').with(@row['abbreviation']).and_return(GeoState.find_by_abbreviation(@row['abbreviation']))
        si.send(:import_state, @row)
      end
      it "sets each method from the hash" do
        si.stub(:get_from_row)
        state.stub(:send)
        StateImporter.state_settings.each do |method, yaml_key|
          si.should_receive(:get_from_row).with(@row, yaml_key).and_return("new-val")
          state.should_receive(:send).with("#{method}=", "new-val")
        end
        GeoState.stub('[]').and_return(state)
        si.send(:import_state, @row)
      end
      it "adds the state to the list of imported states" do
        si.imported_states.size.should == 0
        si.send(:import_state, @row)       
        si.imported_states.size.should == 1 
      end
      it "calls import_localizations" do
        GeoState.stub('[]').and_return(state)
        si.should_receive(:import_localizations).with(state, @row)
        si.send(:import_state, @row)
      end
    end
    
    describe "#import_localizations(state, row)" do
      let(:state) { double(GeoState).as_null_object }
      before(:each) do
        @row = states_hash[:record_0].stringify_keys
        state.stub(:name).and_return("state-name")
        si.stub(:report_any_changes)
      end
      
      it "saves the translated values for each translation key" do
        I18n.available_locales.each do |locale|
          loc = double(StateLocalization)
          state.should_receive(:get_localization).with(locale).and_return(loc)

          si.should_receive(:translate_list_item).with(
            'parties', "independent", locale, "state-name"
          ).and_return("new-val-1")
          
          si.should_receive(:translate_list_item).with(
            'parties', "green", locale, "state-name"
          ).and_return("new-val-2")
          loc.should_receive(:send).with("parties")
          loc.stub(:id)
          loc.should_receive(:send).with("parties=", ["new-val-1", "new-val-2"])
          
          StateImporter.state_localizations.each do |method|
            si.should_receive(:translate_from_row).with(
                @row, method, locale, "state-name"
            ).and_return("new-val")
            loc.should_receive(:send).with(method)
            loc.should_receive(:send).with("#{method}=", "new-val")          
          end
        end
        si.send(:import_localizations, state, @row)
      end
      it "adds the state to the list of imported states" do
        si.imported_locales.size.should == 0
        si.send(:import_localizations, state, @row)       
        si.imported_locales.size.should == I18n.available_locales.size
      end
      
    end

    describe "#import_zip_county_addresses" do
      let(:si) { StateImporter.new }

      it "creates a list of ZipCodeCountyAddress objects" do
        si.import_zip_county_addresses
        # 3 counties, 4 zip codes
        si.imported_zip_addresses.should have(4).zip_code_county_addresses        
        zca = si.imported_zip_addresses.first
        zca.geo_state_id.should == GeoState["LA"].id
        zca.zip.should == "00544"
        zca.county.should == "adams"
        zca.address.should == "AC Office\n117 Baltimore Street\nRoom 106\nGettysburg, LA 17325"
      end
    end
    
    describe "#commit!" do
      let(:si) { StateImporter.new }
      let(:state) { double(GeoState) }
      let(:loc) { double(StateLocalization) }
      let(:zca) { mock_model(ZipCodeCountyAddress) }
      before(:each) do
        state.stub(:save!)
        loc.stub(:save!)
        zca.stub(:save!)
        si.stub(:imported_states).and_return([state])
        si.stub(:imported_locales).and_return([loc])
        si.stub(:imported_zip_addresses).and_return([zca])
      end
      it "saves each state in the imported_states list" do
        state.should_receive(:save!)
        si.commit!
      end
      it "saves each localization in the imported_localizations list" do
        loc.should_receive(:save!)
        si.commit!
      end
      it "deletes all zip_code_county_addresses" do
        ZipCodeCountyAddress.should_receive(:delete_all)
        si.commit!
      end
      it "saves each zip_code_county_address" do
        zca.should_receive(:save!)
        si.commit!
      end
      

    end
    
    describe "#get_from_row(row, key)" do
      it "selects the key from the row when present" do
        si.send(:get_from_row, {'a'=>"b"}, 'a').should == 'b'
      end
      it "selects the key from the defaults when missing" do
        si.stub(:defaults).and_return({'c'=>'d'})
        si.send(:get_from_row, {'a'=>"b"}, 'c').should == 'd'
      end
    end
    
    describe "#translate_from_row(row, key, locale, state_name='')" do
      it "calls the class translate_key" do        
        StateImporter.should_receive(:translate_key).with('b', 'a', 'locale', 'state-name')
        si.send(:translate_from_row, {'a'=>"b"}, 'a','locale','state-name')
        
        StateImporter.should_receive(:translate_key).with('d', 'c', 'locale', 'state-name')
        si.stub(:defaults).and_return({'c'=>'d'})
        si.send(:translate_from_row, {'a'=>"b"}, 'c','locale','state-name')
      end
    end
    
    describe "self.translate_list_item(list_key, item_key, locale, state_name='')" do
      it "translates within the states namespace" do
        I18n.should_receive(:t).with("states.list_key.item_key", 
          :locale=>"locale", 
          :state_name=>"state_name")
        StateImporter.translate_list_item("list_key", "item_key", "locale", "state_name")
      end
    end
    
    describe "self.get_loc_part(key)" do
      it "returns values according to this list" do
        loc_keys = {
          not_participating_tooltip: 'states.tooltips.not_participating', #blank
          race_tooltip: 'states.tooltips.race', #not_required_but_appreciated_with_state_name
          no_party: 'states.no_party_label', #none
          sub_18: 'states.sub_18', # turn_by_next_election
          race_tooltip: 'states.tooltips.race', #required_with_state_name 
          party_tooltip: 'states.tooltips.party', #not_required_can_choose_any
          id_number_tooltip: 'states.tooltips.id_number', #ssn_or_none_5
          sub_18: 'states.sub_18' #be_by_next_election
        }
        loc_keys.each do |key, return_value|
          StateImporter.get_loc_part(key.to_s).should == return_value
        end
      end
    end
  end


end
