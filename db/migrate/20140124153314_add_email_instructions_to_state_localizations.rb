class AddEmailInstructionsToStateLocalizations < ActiveRecord::Migration
  def change
    add_column :state_localizations, :email_instructions, :string
  end
end
