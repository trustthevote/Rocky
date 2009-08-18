class AddAbandonedToRegistrant < ActiveRecord::Migration
  def self.up
    add_column "registrants", "abandoned", :boolean, :default => false, :null => false
  end

  def self.down
    remove_column "registrants", "abandoned"
  end
end
