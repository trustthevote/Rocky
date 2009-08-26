class AddPartyTooltipToStateLocalization < ActiveRecord::Migration
  def self.up
    add_column :state_localizations, :party_tooltip, :string, :limit => 1024
  end

  def self.down
    remove_column :state_localizations, :party_tooltip
  end
end
