class AddJavascriptDisabledToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :javascript_disabled, :boolean, :default=>false
  end

  def self.down
    remove_column :registrants, :javascript_disabled
  end
end
