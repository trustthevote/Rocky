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

describe StateLocalization do
  describe "tooltips" do
    it "should accomodate long tooltips" do
      kilo_chars = "s" * 1024
      loc = StateLocalization.create!(
        :locale => 'en',
        :not_participating_tooltip => kilo_chars,
        :race_tooltip => kilo_chars,
        :id_number_tooltip => kilo_chars,
        :parties => kilo_chars,
        :sub_18 => kilo_chars,
        :registration_deadline => kilo_chars,
        :pdf_instructions => kilo_chars,
        :email_instructions => kilo_chars)

      loc.reload
      assert_equal kilo_chars, loc.not_participating_tooltip
      assert_equal kilo_chars, loc.race_tooltip
      assert_equal kilo_chars, loc.id_number_tooltip
      assert_equal kilo_chars, loc.parties
      assert_equal kilo_chars, loc.sub_18
      assert_equal kilo_chars, loc.registration_deadline
      assert_equal kilo_chars, loc.pdf_instructions
      assert_equal kilo_chars, loc.email_instructions
      
    end
  end
  
end
