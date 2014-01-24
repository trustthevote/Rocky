class ChangeStateLocalizationsToTexts < ActiveRecord::Migration
  def up
    change_column :state_localizations, :parties,  :string, :limit => 1024
    change_column :state_localizations, :sub_18,  :string, :limit => 1024
    change_column :state_localizations, :registration_deadline,  :string, :limit => 1024
    change_column :state_localizations, :pdf_instructions,  :string, :limit => 1024
    change_column :state_localizations, :email_instructions,  :string, :limit => 1024
  end

  def down
    change_column :state_localizations, :registration_deadline, :string
    change_column :state_localizations, :pdf_instructions, :string
    change_column :state_localizations, :email_instructions, :string
  end
end
