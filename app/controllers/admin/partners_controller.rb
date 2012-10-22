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
class Admin::PartnersController < Admin::BaseController

  def index
    @partners = Partner.standard
    @partner_zip = PartnerZip.new(nil)
  end

  def show
    @partner = Partner.find(params[:id])
  end

  def edit
    @partner = Partner.find(params[:id])
  end

  def update
    @partner = Partner.find(params[:id])

    if @partner.update_attributes(params[:partner])
      update_email_templates(@partner, params[:template])
      update_custom_css(@partner, params[:css_files])

      redirect_to [ :admin, @partner ]
    else
      render :edit
    end
  end
  
  def regen_api_key
    @partner = Partner.find(params[:id])
    @partner.generate_api_key!
    redirect_to admin_partner_path(@partner)
  end
  
  

  private

  def update_email_templates(partner, templates)
    (templates || {}).each do |name, body|
      EmailTemplate.set(partner, name, body)
    end
  end

  def update_custom_css(partner, css_files)
    paf = PartnerAssetsFolder.new(partner)
    (css_files || {}).each do |name, data|
      paf.update_css(name, data)
    end
  end

end
