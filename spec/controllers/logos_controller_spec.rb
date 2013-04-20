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

class Paperclip::Attachment
  def post_process
    # mocked out!
  end
end

describe LogosController do
  render_views

  before(:each) do
    activate_authlogic
    @partner = FactoryGirl.create(:partner)
    PartnerSession.create(@partner)
  end

  after(:each) do
    FileUtils.rm_rf(Rails.root.join("tmp/system/logos"))
  end

  it "shows upload page" do
    get :show
    assert_response :success
    assert_template "show"
    assert_not_nil assigns[:partner]
  end

  it "can upload a logo" do
    logo_fixture = fixture_file_upload('/files/partner_logo.jpg','image/jpeg')
    put :update, :partner => { :logo => logo_fixture }
    assert_redirected_to partner_logo_url
    @partner.reload
    assert_match %r{logos/\d+/header/partner_logo.jpg}, @partner.logo.url(:header)
    assert 0 < @partner.logo_file_size
  end

  it "shows an error message when you upload something crazy" do
    logo_fixture = fixture_file_upload('/files/crazy.txt','text/plain')
    put :update, :partner => { :logo => logo_fixture }
    assert_response :success
    assert_match /JPG, GIF, or PNG/, assigns[:partner].errors.on(:logo)
  end

  describe "shows an error message when you upload nothing" do
    it "no partner params" do
      put :update, :partner => {}
      assert_response :success
      assert_match /You must select an image file to upload/, assigns[:partner].errors.on(:logo)
    end

    it "no partner[logo] param" do
      put :update, :partner => { :logo => "" }
      assert_response :success
      assert_match /You must select an image file to upload/, assigns[:partner].errors.on(:logo)
    end
  end

  it "shows an error message when you upload a HUGE file" do
    unless File.exist?("/tmp/over_a_megabyte.jpg")
      File.open("/tmp/over_a_megabyte.jpg", "w") do |big_file|
        big_file.puts "1234567890\n" * 100_000
      end
    end
    File.open("/tmp/over_a_megabyte.jpg") do |big_file|
      put :update, :partner => { :logo => big_file }
    end
    assert_response :success
    assert_match /megabyte/, assigns[:partner].errors.on(:logo)
  end

  it "destroys logo when there is a logo" do
    File.open(File.join(fixture_files_path, "partner_logo.jpg"), "r") do |logo|
      @partner.update_attributes(:logo => logo)
      assert @partner.custom_logo?
    end
    delete :destroy
    assert_redirected_to partner_logo_url
    @partner = Partner.find(@partner.id)  # paperclip's state isn't reset by a #reload
    assert !@partner.custom_logo?
  end
end
