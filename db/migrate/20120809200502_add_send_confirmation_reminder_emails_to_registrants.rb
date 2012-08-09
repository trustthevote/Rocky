class AddSendConfirmationReminderEmailsToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :send_confirmation_reminder_emails, :boolean, :default=>false
  end

  def self.down
    remove_column :registrants, :send_confirmation_reminder_emails
  end
end
