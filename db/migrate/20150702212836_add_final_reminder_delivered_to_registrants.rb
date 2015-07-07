class AddFinalReminderDeliveredToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :final_reminder_delivered, :boolean, :default=>false
    # default is false, but need to set all prior registrants to delivered
    Registrant.update_all(final_reminder_delivered: true)
  end
end
