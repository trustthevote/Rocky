class AddTrackingIdToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :tracking_id, :string
  end

  def self.down
    remove_column :registrants, :tracking_id
  end
end
