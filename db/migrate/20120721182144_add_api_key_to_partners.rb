class AddApiKeyToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :api_key, :string, :limit=>40, :default=>""
  end

  def self.down
    remove_column :partners, :api_key
  end
end
