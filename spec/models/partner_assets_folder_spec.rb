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
require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe PartnerAssetsFolder do

  before(:each) do 
    @partner = FactoryGirl.create(:partner)
    @partner.stub(:partner_root).and_return("partners/TEST")
    @paf = PartnerAssetsFolder.new(@partner)
  end

  after  {  @paf.directory.files.each {|f| f.destroy} }

  describe 'update_css' do
    it 'should save asset file' do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_css('application', @file)
      @partner.application_css_present?.should be_truthy
    end

    context 'updating' do
      before do
        @file = File.new("#{fixture_files_path}/sample.css")
        @alt  = File.new("#{fixture_files_path}/alt.css")
        @paf.update_css('application', @file)
        @paf.update_css('application', @alt)
      end

      it 'should replace asset file' do
        open(@partner.application_css_url).read.should == "alt\n"
      end

      it 'should create the versioned copy' do
        css_files = @paf.old_directory.files
        css_files.count.should == 1
        css_files.first.key.should match /\/application-#{Time.now.strftime("%Y%m%d%H")}\d{4}\.css$/
      end
    end
  end

  describe 'list_assets' do
    before do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_css('application', @file)
      @paf.update_css('application', @file)
      @paf.update_asset('bg.png', @file)
    end

    it 'should list assets only' do
      @paf.list_assets.should == [ 'application.css', 'bg.png' ]
    end
  end

  describe 'delete_asset' do
    before do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_css('application', @file)
      
    end

    it 'should delete asset' do
      @paf.delete_asset('application.css')
      @paf.list_assets.should == []
    end

    it 'should not error on removing unknown asset' do
      @paf.delete_asset('unknown')
      @paf.list_assets.should == [ 'application.css' ]
    end
  end

  describe 'upload_asset' do
    it 'should upload an asset' do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_asset('sample.css', @file)
      @paf.list_assets.should == [ 'sample.css' ]
    end
  end
end
