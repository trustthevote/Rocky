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
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :ensure_https

  before_filter :authenticate_everything, :if => lambda { !%w{ development test production }.include?(Rails.env) }

  protected

  # override in subclass controller if plain HTTP is allowed
  def require_https?
    true
  end

  def ensure_https
    if RockyConf.use_https && require_https? && !request.ssl?
      flash.keep
      url = URI.parse(request.url)
      url.scheme = "https"
      redirect_to(url.to_s)
      false
    end
  end
  
  def authenticate_everything
    authenticate_or_request_with_http_basic("Translation UI") do |user, password|
      pass = Settings.admin_password
      pass.present? && user == 'rtvdemo' && password == 'bullwinkle'
    end
  end
  
  
end
