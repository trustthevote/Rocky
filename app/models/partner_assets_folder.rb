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

  attr_reader :connection
  
  def initialize(partner)
    @partner = partner
    @connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY']
    })
    
  end
  
  def directory
    connection.directories.get(@partner.partner_assets_bucket, prefix: @partner.assets_path)
  end
  
  def old_directory
    connection.directories.get(@partner.partner_assets_bucket, prefix: @partner.absolute_old_assets_path)
  end
    
  def self.sync_all
    Partner.all.each do |p|
      PartnerAssetsFolder.new(p).sync_from_local
    end
  end
  
  def sync_from_local
    Dir.glob(Rails.root.join("public", @partner.assets_path, '*.*')).each do |fn|
      update_asset(File.basename(fn), File.open(fn))
    end
  end
  

  # Updates the css
  def update_css(name, file)
    update_path(css_path(name), file)
  end
  
  def write_css(name, content)
    write_path(css_path(name), content)
  end

  # Updates asset
  def update_asset(name, file)
    path = path_from_name(name)
    update_path(path, file)
  end
  def write_asset(name, content)
    write_path(path_from_name(name), content)
  end
  
  def path_from_name(name)
    File.join(@partner.assets_path, File.basename(name))
  end

  # Returns the list of all assets in the folder
  def list_assets
    directory.files.collect {|f| f.public_url.nil? ?  nil : f }.compact.map { |n| File.basename(n.key) }
    #Dir.glob(File.join(@partner.assets_path, '*.*')).map { |n| File.basename(n) }
  end

  # Deletes the asset
  def delete_asset(name)
    (f = existing(File.join(@partner.assets_path, File.basename(name)))) && f.destroy
  end


  def asset_url(name)
    asset_file(name) && asset_file(name).public_url
  end

  def asset_file(name)
    directory.files.get(path_from_name(name))
  end
  
  def asset_file_exists?(name)
    !asset_file(name).nil?
  end

  private

  def css_path(name)
    @partner.send("#{name}_css_path")
  end

  def ensure_dir(path)
    FileUtils.mkdir_p File.dirname(path)
  end
  
  def update_file(path, file)
    if file.file_name == PartnerAssets::PDF_LOGO
      path = absolute_pdf_logo_path(file.exension)
      ensure_dir(path)
      File.open(path, 'wb') { |f| f.write(file.read) }
    else
      write_file(path, file.read)
    end
  end

  def write_file(path, content)
    directory.files.create(
      :key    => path,
      :body   => content,
      :public => true
    )    
  end

  def update_path(path, file)
    if file.respond_to?(:read)
      create_version(path)
      update_file(path, file)
    end
  end
  def write_path(path, content)
    create_version(path)
    write_file(path, content)
  end
  
  def existing(path)
     directory.files.get(path)
  end
  

  def create_version(path)
    return unless (file = existing(path))

    ext  = File.extname(path)
    name = File.basename(path, ext)
    ts   = Time.now.strftime("%Y%m%d%H%M%S")

    archive_path = File.join(@partner.absolute_old_assets_path, "#{name}-#{ts}#{ext}")
    
    directory.files.create :key => archive_path, :body => file.body, :public=>false
    
    #FileUtils.cp path, archive_path
  end
  
end
