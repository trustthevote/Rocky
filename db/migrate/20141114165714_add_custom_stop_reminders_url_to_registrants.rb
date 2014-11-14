class AddCustomStopRemindersUrlToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :custom_stop_reminders_url, :string
  end
end
