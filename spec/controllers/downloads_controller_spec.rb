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

describe DownloadsController do
  integrate_views

  describe "when PDF is ready" do
    before(:each) do
      @registrant = FactoryGirl.create(:step_5_registrant)
      stub(@registrant).merge_pdf { `touch #{@registrant.pdf_file_path}` }
      @registrant.generate_pdf
      @registrant.save!
    end

    it "provides a link to download the PDF" do
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "show"
      assert_select "span.button a[target=_blank]"
      assert_select "span.button a[onclick]"
    end

    after(:each) do
      `rm #{@registrant.pdf_file_path}`
    end
  end

  describe "when PDF is not ready" do
    before(:each) do
      @registrant = FactoryGirl.create(:step_5_registrant)
    end

    it "provides a link to download the PDF" do
      assert !@registrant.pdf_ready?
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "preparing"
    end

    it "times out preparing page after 30 seconds" do
      Registrant.update_all("updated_at = '#{35.seconds.ago.to_s(:db)}'", "id = #{@registrant.id}")
      assert !@registrant.pdf_ready?
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_redirected_to registrant_finish_url(@registrant)
    end
  end

end
