class AddBuildingViaApiCallToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :building_via_api_call, :boolean, :default=>false
  end

  def self.down
    remove_column :registrants, :building_via_api_call
  end
end
