class AddIndexOnStateLocalizationState < ActiveRecord::Migration
  def self.up
    add_index :state_localizations, :state_id
  end

  def self.down
    remove_index :state_localizations, :state_id
  end
end
