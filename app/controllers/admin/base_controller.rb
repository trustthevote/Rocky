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
class Admin::BaseController < ApplicationController

  layout 'admin'
  before_filter :redirect_ui_role

  skip_before_filter :authenticate_everything
  before_filter :authenticate, :if => lambda { !%w{ development test }.include?(Rails.env) }

  private

  def authenticate
    authenticate_or_request_with_http_basic("RTV Admin Console") do |user, password|
      pass = Settings.admin_password
      pass.present? && user == RockyConf.admin_username && password == pass
    end
  end

  def redirect_ui_role
    if ENV['ROCKY_ROLE'] == 'UI'
      redirect_to "#{RockyConf.api_host_name }/admin"
    end
  end


end
