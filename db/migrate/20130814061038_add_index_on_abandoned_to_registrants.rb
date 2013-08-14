class AddIndexOnAbandonedToRegistrants < ActiveRecord::Migration
  def self.up
    add_index :registrants, :abandoned
  end

  def self.down
    remove_index :registrants, :abandoned
  end
end
