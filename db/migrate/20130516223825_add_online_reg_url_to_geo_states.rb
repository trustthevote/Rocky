class AddOnlineRegUrlToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :online_registration_url, :string
  end
end
