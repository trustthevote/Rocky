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

describe Mergable do
  describe "attributes" do
    before(:each) do
      @registrant = Factory.create(:maximal_registrant)
      @doc = Nokogiri::XML(@registrant.to_xfdf)
    end
    it "should output us citizen" do
      assert_equal  @registrant.us_citizen? ? 'Yes' : 'No',
                    @doc.css('xfdf fields field[name="us_citizen"] value').text
    end
    it "should output will be 18" do
      assert_equal  @registrant.will_be_18_by_election? ? 'Yes' : 'No',
                    @doc.css('xfdf fields field[name="will_be_18_by_election"] value').text
    end

    it "should output name title" do
      assert_equal  @registrant.name_title,
                    @doc.css('xfdf fields field[name="name.title"] value').text
    end
    it "should output first name" do
      assert_equal  @registrant.first_name,
                    @doc.css('xfdf fields field[name="name.first"] value').text
    end
    it "should output middle name" do
      assert_equal  @registrant.middle_name,
                    @doc.css('xfdf fields field[name="name.middle"] value').text
    end
    it "should output last name" do
      assert_equal  @registrant.last_name,
                    @doc.css('xfdf fields field[name="name.last"] value').text
    end
    it "should output name suffix" do
      assert_equal  @registrant.name_suffix,
                    @doc.css('xfdf fields field[name="name.suffix"] value').text
    end

    it "should output home address street" do
      assert_equal  @registrant.home_address,
                    @doc.css('xfdf fields field[name="home_address.street"] value').text
    end
    it "should output home address unit" do
      assert_equal  @registrant.home_unit,
                    @doc.css('xfdf fields field[name="home_address.unit"] value').text
    end
    it "should output home address city" do
      assert_equal  @registrant.home_city,
                    @doc.css('xfdf fields field[name="home_address.city"] value').text
    end
    it "should output home address state" do
      assert_equal  @registrant.home_state.abbreviation,
                    @doc.css('xfdf fields field[name="home_address.state"] value').text
    end
    it "should output home address zip code" do
      assert_equal  @registrant.home_zip_code,
                    @doc.css('xfdf fields field[name="home_address.zip_code"] value').text
    end

    it "should output mailing address street" do
      assert_equal  "#{@registrant.mailing_address} #{@registrant.mailing_unit}",
                    @doc.css('xfdf fields field[name="mailing_address.street"] value').text
    end
    it "should output mailing address city" do
      assert_equal  @registrant.mailing_city,
                    @doc.css('xfdf fields field[name="mailing_address.city"] value').text
    end
    it "should output mailing address state" do
      assert_equal  @registrant.mailing_state.abbreviation,
                    @doc.css('xfdf fields field[name="mailing_address.state"] value').text
    end
    it "should output mailing address zip code" do
      assert_equal  @registrant.mailing_zip_code,
                    @doc.css('xfdf fields field[name="mailing_address.zip_code"] value').text
    end

    it "should output date of birth" do
      assert_equal  @registrant.pdf_date_of_birth,
                    @doc.css('xfdf fields field[name="date_of_birth"] value').text
    end
    it "should output phone" do
      assert_equal  @registrant.phone,
                    @doc.css('xfdf fields field[name="phone_number"] value').text
    end
    it "should output state ID number" do
      assert_equal  @registrant.state_id_number,
                    @doc.css('xfdf fields field[name="id_number"] value').text
    end
    it "should output party" do
      assert_equal  @registrant.party.to_s,
                    @doc.css('xfdf fields field[name="party"] value').text
    end
    it "should output previous name title" do
      assert_equal  @registrant.prev_name_title,
                    @doc.css('xfdf fields field[name="previous_name.title"] value').text
    end
    it "should output previous first name" do
      assert_equal  @registrant.prev_first_name,
                    @doc.css('xfdf fields field[name="previous_name.first"] value').text
    end
    it "should output previous middle name" do
      assert_equal  @registrant.prev_middle_name,
                    @doc.css('xfdf fields field[name="previous_name.middle"] value').text
    end
    it "should output previous last name" do
      assert_equal  @registrant.prev_last_name,
                    @doc.css('xfdf fields field[name="previous_name.last"] value').text
    end
    it "should output previous name suffix" do
      assert_equal  @registrant.prev_name_suffix,
                    @doc.css('xfdf fields field[name="previous_name.suffix"] value').text
    end

    it "should output previous address street" do
      assert_equal  @registrant.prev_address,
                    @doc.css('xfdf fields field[name="previous_address.street"] value').text
    end
    it "should output previous address unit" do
      assert_equal  @registrant.prev_unit,
                    @doc.css('xfdf fields field[name="previous_address.unit"] value').text
    end
    it "should output previous address city" do
      assert_equal  @registrant.prev_city,
                    @doc.css('xfdf fields field[name="previous_address.city"] value').text
    end
    it "should output previous address state" do
      assert_equal  @registrant.prev_state.abbreviation,
                    @doc.css('xfdf fields field[name="previous_address.state"] value').text
    end
    it "should output previous address zip code" do
      assert_equal  @registrant.prev_zip_code,
                    @doc.css('xfdf fields field[name="previous_address.zip_code"] value').text
    end
  end

  describe "race" do
    it "should output race" do
      @registrant = Factory.create(:maximal_registrant)
      stub(@registrant).requires_race? { true }
      @doc = Nokogiri::XML(@registrant.to_xfdf)
      assert_equal  @registrant.race,
                    @doc.css('xfdf fields field[name="race"] value').text
    end
    it "should not output race as decline to state" do
      @registrant = Factory.create(:maximal_registrant, :race => "Decline to State")
      stub(@registrant).requires_race? { true }
      @doc = Nokogiri::XML(@registrant.to_xfdf)
      assert_equal  "",
                    @doc.css('xfdf fields field[name="race"] value').text
    end
    it "should not output race if it is not required" do
      @registrant = Factory.create(:maximal_registrant, :race => "Multi-racial")
      stub(@registrant).requires_race? { false }
      @doc = Nokogiri::XML(@registrant.to_xfdf)
      assert_equal  "",
                    @doc.css('xfdf fields field[name="race"] value').text
    end
  end

  describe "barcode" do
    before(:each) do
      @registrant = Factory.build(:maximal_registrant)
      @registrant.id = 42_000_000
      @doc = Nokogiri::XML(@registrant.to_xfdf)
    end

    it "generates ppp-nnnnnn barcode text" do
      assert_equal  "*RTV-0P07EO*", @registrant.pdf_barcode
    end

    it "should output barcode text" do
      assert_equal  @registrant.pdf_barcode,
                    @doc.css('xfdf fields field[name="uidbarcode"] value').text
    end
  end
end
