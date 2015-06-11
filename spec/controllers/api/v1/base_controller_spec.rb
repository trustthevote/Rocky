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

describe Api::V1::BaseController do

  describe 'jsonp' do
    before { @c = Api::V1::BaseController.new }

    it 'should render plain JSON' do
      @c.stub(:params) { {} }
      @c.stub(:render).with(:json => { :data => 'field' }, :status => 400)
      @c.send(:jsonp, { :data => 'field' }, :status => 400)
    end

    it 'should render JSONP callback' do
      @c.stub(:params) { { :callback => 'cb' } }
      @c.stub(:render_to_string).with(:json => :data) { 'json_value' }
      @c.stub(:render).with(:text => 'cb(json_value);', :status => 400)
      @c.send(:jsonp, :data, :status => 400)
    end
  end

end
