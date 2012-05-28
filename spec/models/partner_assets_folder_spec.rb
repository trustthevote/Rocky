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

describe PartnerAssetsFolder do

  before { @partner = Factory(:partner) }
  before { stub(@partner).assets_root { "#{RAILS_ROOT}/tmp/test_assets" } }
  before { @paf = PartnerAssetsFolder.new(@partner) }

  after  { FileUtils.rm_r("#{RAILS_ROOT}/tmp/test_assets") }

  describe 'update_css' do
    it 'should save asset file' do
      @file = File.new("#{fixture_path}/files/sample.css")
      @paf.update_css('application', @file)
      @partner.application_css_present?.should be_true
    end

    context 'updating' do
      before do
        @file = File.new("#{fixture_path}/files/sample.css")
        @alt  = File.new("#{fixture_path}/files/alt.css")
        @paf.update_css('application', @file)
        @paf.update_css('application', @alt)
      end

      it 'should replace asset file' do
        File.open(@partner.absolute_application_css_path, 'r').read.should == "alt\n"
      end

      it 'should create the versioned copy' do
        css_files = Dir.glob(File.join(@partner.absolute_old_assets_path, '*.css'))
        css_files.count.should == 1
        css_files.first.should match /\/application-#{Time.now.strftime("%Y%m%d%H")}\d{4}\.css$/
      end
    end

    it 'should error out for unknown stylesheet name'
  end

end
