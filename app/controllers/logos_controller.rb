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
class LogosController < PartnerBase
  before_filter :require_partner

  def show
    @partner = current_partner
  end

  def update
    @partner = current_partner
    if params[:partner].blank? || params[:partner][:logo].blank?
      @partner.errors.add(:logo, "You must select an image file to upload")
      render "show"
    elsif @partner.update_attributes(:logo => params[:partner][:logo])
      flash[:success] = "You have updated your logo."
      redirect_to partner_logo_url
    else
      render "show"
    end
  end

  def destroy
    @partner = current_partner
    @partner.logo.destroy
    @partner.save!
      flash[:success] = "You have deleted your logo."
    redirect_to partner_logo_url
  end
end
