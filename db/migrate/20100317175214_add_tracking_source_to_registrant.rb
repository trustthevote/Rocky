class AddTrackingSourceToRegistrant < ActiveRecord::Migration
  def self.up
    add_column "registrants", "tracking_source", :string
  end

  def self.down
    remove_column "registrants", "tracking_source"
  end
end
