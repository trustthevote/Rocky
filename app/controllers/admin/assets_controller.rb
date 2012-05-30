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
class Admin::AssetsController < Admin::BaseController

  # Lists assets
  def index
    @assets = assets_folder.list_assets
  end

  # Uploads new asset
  def create
    asset_file = params[:asset].try(:[], :file)

    if asset_file
      name = asset_file.original_filename
      assets_folder.update_asset(name, asset_file)
    end

    redirect_to [ :admin, partner, :assets ]
  end

  # Destroys the asset
  def destroy
    assets_folder.delete_asset(params[:name])
    redirect_to [ :admin, partner, :assets ]
  end

  private

  def assets_folder
    @assets_folder ||= PartnerAssetsFolder.new(partner)
  end

  def partner
    @partner ||= Partner.find(params[:partner_id])
  end

end
