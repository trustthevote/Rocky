class ChangeLocaleColumnLimitForStateLocalizations < ActiveRecord::Migration
  def up
    change_column :state_localizations, :locale, :string, :limit => 64
  end

  def down
    change_column :state_localizations, :locale, :string, :limit => 2
  end
end
