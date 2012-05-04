class AddWhitelabeledToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :whitelabeled, :boolean
    add_index :partners, :whitelabeled
  end

  def self.down
    remove_column :partners, :whitelabeled
  end
end
