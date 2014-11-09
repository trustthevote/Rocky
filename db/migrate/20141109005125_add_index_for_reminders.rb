class AddIndexForReminders < ActiveRecord::Migration
  def up
    add_index :registrants, [:reminders_left, :updated_at]
  end

  def down
    remove_index :registrants, [:reminders_left, :updated_at]
  end
end
