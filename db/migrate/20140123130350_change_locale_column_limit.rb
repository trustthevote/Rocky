class ChangeLocaleColumnLimit < ActiveRecord::Migration
  def up
    change_column :registrants, :locale, :string, :limit => 64
  end

  def down
    change_column :registrants, :locale, :string, :limit => 2
  end
end
