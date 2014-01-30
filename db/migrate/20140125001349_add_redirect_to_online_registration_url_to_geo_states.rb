class AddRedirectToOnlineRegistrationUrlToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :redirect_to_online_registration_url, :boolean
  end
end
