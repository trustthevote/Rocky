class AddSub18ToStateLocalizations < ActiveRecord::Migration
  def self.up
    add_column "state_localizations", "sub_18", :string
  end

  def self.down
    remove_column "state_localizations", "sub_18"
  end
end
