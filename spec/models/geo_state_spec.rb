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
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GeoState do
  it "should cache by state abbreviation" do
    assert_equal(GeoState['CA'].object_id, GeoState['CA'].object_id)
  end

  it "should cache by id" do
    assert_equal(GeoState['CA'].object_id, GeoState[5].object_id)
    assert_equal(GeoState[5].object_id, GeoState[5].object_id)
  end

  it "constructs array of name/abbrev tuples in alphabetical order" do
    states = GeoState.collection_for_select
    assert_equal 51, states.size
    names, abbrevs = states.transpose
    assert_equal %w(Alabama Alaska Arizona Arkansas California), names[0..4]
    assert_equal %w(AL AK AZ AR CA), abbrevs[0..4]
  end

  describe "zip code" do
    before(:each) do
      # set up test mapping data
    end

    it "returns nil for bad zip codes" do
      assert_nil GeoState.for_zip_code("00000")
    end

    it "finds the state for a given zip code prefix" do
      assert_equal GeoState["CA"], GeoState.for_zip_code("90001")
      assert_equal GeoState["CA"], GeoState.for_zip_code("94110")
      assert_equal GeoState["CA"], GeoState.for_zip_code("96110")
    end

    it "gives precedence to 5 digit exceptions" do
      assert_equal GeoState["CT"], GeoState.for_zip_code("06301")
      assert_equal GeoState["NY"], GeoState.for_zip_code("06390") # exception
      assert_equal GeoState["CT"], GeoState.for_zip_code("06391")
    end

    it "maps all our 3 digit prefixes to valid states" do
      assert GeoState.zip3map.keys.all? {|zip| GeoState.for_zip_code(zip) }
    end
  end

  describe "#online_reg_enabled?(locale, reg)" do
    let(:r) { Registrant.new(:locale=>"es", :has_state_license=>true)}
    it "returns true if the state is in the config list without locale restrictions" do
      RockyConf.stub(:states_with_online_registration) { ["AZ"] }
      RockyConf.stub(:ovr_states) { {} }
      s = GeoState.new(:abbreviation=>"AZ")
      s.online_reg_enabled?(r.locale, r).should be_true
    end
    it "returns true if the state is in the config list and registrant's locale is included" do
      RockyConf.stub(:states_with_online_registration) { ["AZ"] }
      RockyConf.stub(:ovr_states) { {"AZ"=>{"languages"=>["en", "es"]}} }
      s = GeoState.new(:abbreviation=>"AZ")
      s.online_reg_enabled?(r.locale, r).should be_true
    end
    it "returns false if the state is in the config list but the registrants locale is not enabled" do
      RockyConf.stub(:states_with_online_registration) { ["AZ"] }
      RockyConf.stub(:ovr_states) { {"AZ"=>{"languages" => ["en", "ko"]}} }      
      s = GeoState.new(:abbreviation=>"AZ")
      s.online_reg_enabled?(r.locale, r).should be_false
    end
    it "returns false if the state is not in the config list" do
      RockyConf.stub(:states_with_online_registration) { ["CA"] }
      RockyConf.stub(:ovr_states) { {"CA"=>["en", "es"]} }      
      s = GeoState.new(:abbreviation=>"AZ")
      s.online_reg_enabled?(r.locale, r).should be_false      
    end
  end

  describe "county addresses" do
    #zip_code_database source http://www.unitedstateszipcodes.org/zip-code-database/
    before(:each) do
      GeoState.reset_county_zip_codes
      GeoState.reset_county_registrar_addresses
      
      GeoState.stub(:county_addresses_file).and_return(
        Rails.root.join("spec/fixtures/files/county_addressing/county_addresses.csv")
      )
      GeoState.stub(:zip_code_database_file).and_return(
        Rails.root.join("spec/fixtures/files/county_addressing/zip_code_database.csv")
      )
    end

    describe "self#county_registrar_addresses" do
      it "returns a hash of state_abbr=>county=>address with blank lines removed" do
        GeoState.county_registrar_addresses.should == {
          "LA"=>{
              "adams" => ["AC Office\n117 Baltimore Street\nRoom 106\nGettysburg, LA 17325", ["00544"], "city"],
              "allegheny parish" => ["A Office\n542 Forbes Avenue\nSuite 609\nPittsburgh, LA 15219-2913", ["00501", "00502"], "county"]
            },
          "NY"=>{
            "adjuntas county"=>["AC2 Office\n542 Forbes Avenue\nPittsburgh, NY 15219-2913", ["00601"], "county"]
          }
        }
      end
      context "when a county isn't in the zip file" do
        before(:each) do
          GeoState.stub(:zip_code_database_file).and_return(
            Rails.root.join("spec/fixtures/files/county_addressing/zip_code_database_missing_counties.csv")
          )
        end
        it "raise a list of missing counties" do
          expect { GeoState.county_registrar_addresses }.to raise_error(StandardError, "The following counties are missing from the zip code database:\nLA: Adams City\nNY: AdJuntas County")         
        end
      end
    end
  end

end
