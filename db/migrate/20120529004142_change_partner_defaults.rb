class ChangePartnerDefaults < ActiveRecord::Migration
  def self.up
    change_column_default :partners, :ask_for_volunteers, true
    change_column_default :partners, :whitelabeled, false
  end

  def self.down
    change_column_default :partners, :ask_for_volunteers, nil
    change_column_default :partners, :whitelabeled, nil
  end
end
