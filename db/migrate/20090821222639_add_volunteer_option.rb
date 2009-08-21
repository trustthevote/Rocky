class AddVolunteerOption < ActiveRecord::Migration
  def self.up
    add_column :partners, :ask_for_volunteers, :boolean
    add_column :registrants, :volunteer, :boolean
  end

  def self.down
    remove_column :partners, :ask_for_volunteers
    remove_column :registrants, :volunteer
  end
end
