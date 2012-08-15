class AddFinishIframeUrlToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :finish_iframe_url, :string
  end

  def self.down
    remove_column :partners, :finish_iframe_url
  end
end
