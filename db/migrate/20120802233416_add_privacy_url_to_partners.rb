class AddPrivacyUrlToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :privacy_url, :string
  end

  def self.down
    remove_column :partners, :privacy_url
  end
end
