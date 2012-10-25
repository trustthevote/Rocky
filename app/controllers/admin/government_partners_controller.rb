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
class Admin::GovernmentPartnersController < Admin::PartnersController
  def index
    @partners = Partner.government
  end
  
  def new
    @partner = Partner.new
  end
  
  def create
    @partner = Partner.new(params[:partner].merge(:is_government_partner=>true))
    @partner.generate_username
    @partner.generate_random_password
    if @partner.save
      redirect_to :action=>:index
    else
      render :action=>:new
    end
  end
  
  def update
    @partner = Partner.find(params[:id])

    if @partner.update_attributes(params[:partner])
      update_email_templates(@partner, params[:template])
      update_custom_css(@partner, params[:css_files])

      redirect_to :action=>:show, :id=>@partner
    else
      render :edit
    end
  end
  
  
end