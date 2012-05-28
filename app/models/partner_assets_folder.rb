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
class PartnerAssetsFolder

  def initialize(partner)
    @partner = partner
  end

  def update_css(name, file)
    path = css_path(name)

    create_version(path)
    update_file(path, file)
  end

  private

  def css_path(name)
    @partner.send("absolute_#{name}_css_path")
  end

  def ensure_dir(path)
    FileUtils.mkdir_p File.dirname(path)
  end

  def update_file(path, file)
    ensure_dir(path)
    File.open(path, 'wb') { |f| f.write(file.read) }
  end

  def create_version(path)
    return unless File.exists?(path)

    ext  = File.extname(path)
    name = File.basename(path, ext)
    ts   = Time.now.strftime("%Y%m%d%H%M%S")

    archive_path = File.join(@partner.absolute_old_assets_path, "#{name}-#{ts}#{ext}")
    ensure_dir(archive_path)
    FileUtils.cp path, archive_path
  end

end
