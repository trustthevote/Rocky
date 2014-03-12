class AddStateOvrDataToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :state_ovr_data, :text
  end
end
