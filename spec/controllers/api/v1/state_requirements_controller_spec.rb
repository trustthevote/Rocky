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
require File.expand_path(File.dirname(__FILE__) + '/../../../rails_helper')

describe Api::V1::StateRequirementsController do

  describe 'show' do
    it 'should report unsupported language' do
      expect_api_error :message => 'Unsupported language'
      state_requirements { raise V1::UnsupportedLanguageError }
    end

    it 'should report invalid state' do
      expect_api_error :message => 'Invalid state ID'
      state_requirements { raise ArgumentError.new('Invalid state ID') }
    end

    it 'should return data' do
      expect_api_response :result
      state_requirements { :result }
    end
  end

  private

  def state_requirements(&block)
    query = { :lang => nil, :home_state_id => nil, :home_zip_code => nil, :date_of_birth => nil }
    V1::StateRequirements.stub(:find).with(query, &block)
    get :show, :format => 'json', :query => query
  end

end
