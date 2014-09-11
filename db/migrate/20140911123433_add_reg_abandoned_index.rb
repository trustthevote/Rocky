class AddRegAbandonedIndex < ActiveRecord::Migration
  def up
    add_index :registrants, [:abandoned, :status, :updated_at], :name=>:registrant_stale
    
  end
  

  def down
    remove_index :registrants, :name=>:registrant_stale
  end
end
