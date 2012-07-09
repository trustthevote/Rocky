class AddUsingStateOnlineRegistrationToRegistrants < ActiveRecord::Migration
  def self.up
    add_column :registrants, :using_state_online_registration, :boolean, :default=>false
  end

  def self.down
    remove_column :registrants, :using_state_online_registration
  end
end
