class AddHasStateLicenseToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :has_state_license, :boolean
  end

  def self.down
    remove_column :registrants, :has_state_license
  end
end
