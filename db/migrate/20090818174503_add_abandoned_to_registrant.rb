class AddAbandonedToRegistrant < ActiveRecord::Migration
  def self.up
    add_column "registrants", "abandoned", :boolean
  end

  def self.down
    remove_column "registrants", "abandoned"
  end
end
