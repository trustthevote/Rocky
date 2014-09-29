class ChangeParterAskForVolunteersDefaultToFalse < ActiveRecord::Migration
  def up
    change_column_default :partners, :ask_for_volunteers, false
  end

  def down
    change_column_default :partners, :ask_for_volunteers, true
  end
end
