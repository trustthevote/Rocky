class AddShortFormToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :short_form, :boolean, :default=>false
  end

  def self.down
    remove_column :registrants, :short_form
  end
end
