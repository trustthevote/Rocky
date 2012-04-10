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

describe StateRequirements do

  context 'error' do
    it 'if the state is not found' do
      lambda {
        StateRequirements.find(:home_state_id => 'ZZ')
      }.should raise_error StateRequirements::INVALID_STATE_ID
    end

    it 'if the zip code is invalid' do
      lambda {
        StateRequirements.find(:home_zip_code => '00000')
      }.should raise_error StateRequirements::INVALID_ZIP
    end

    it 'if the zip code has invalid format' do
      lambda {
        StateRequirements.find(:home_zip_code => '06390abc')
      }.should raise_error StateRequirements::INVALID_ZIP
    end

    it 'if the zip does not match the state' do
      lambda {
        StateRequirements.find(:home_state_id => 'AK', :home_zip_code => '06390')
      }.should raise_error StateRequirements::NO_ZIP_MATCH
    end

    it 'if neither state ID nor ZIP code are given' do
      lambda { StateRequirements.find({}) }.should raise_error StateRequirements::MISSING_ID_OR_ZIP
    end

    it 'if birth date has invalid format' do
      lambda {
        StateRequirements.find(:home_state_id => 'CA', :lang => 'en', :date_of_birth => 'invalid_format')
      }.should raise_error StateRequirements::BAD_DOB_FORMAT
    end

    it 'if age is invalid' do
      lambda {
        StateRequirements.find(:home_state_id => 'CA', :lang => 'en', :date_of_birth => 5.days.ago.strftime('%Y-%m-%d'))
      }.should raise_error 'if you will turn 18 by the next election' # see the message in fixtures state_localizations.yml
    end

    it 'if the language is unsupported' do
      lambda {
        StateRequirements.find(:home_state_id => 'AK', :lang => 'ru')
      }.should raise_error UnsupportedLanguageError
    end

    it 'if state is not participating' do
      query = { :lang => 'en' }
      state = GeoState.new(:participating => false)
      locale = mock(StateLocalization.new).not_participating_tooltip { 'not participating' }

      mock(StateRequirements).find_state(query) { state }
      mock(StateRequirements).get_locale(state, 'en') { locale }

      lambda {
        StateRequirements.find(query)
      }.should raise_error 'not participating'
    end
  end

  it 'should return data' do
    StateRequirements.find(:home_state_id => 'CA', :lang => 'en').should == {
      :requires_party     => true,
      :id_number_msg      => nil,
      :requires_party_msg => nil,
      :sos_address        => nil,
      :no_party_msg       => "Decline to State",
      :sos_phone          => nil,
      :party_list         => [ "Democratic", "Green", "Libertarian", "Republican" ],
      :sos_url            => nil,
      :requires_race      => true,
      :id_length_min      => nil,
      :sub_18_msg         => "if you will turn 18 by the next election",
      :requires_race_msg  => nil,
      :id_length_max      => nil }
  end
end
