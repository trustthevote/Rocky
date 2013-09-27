class AddRegDeadlineToStateLocalizations < ActiveRecord::Migration
  def change
    add_column :state_localizations, :registration_deadline, :string
  end
end
