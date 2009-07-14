class CreateGeoStates < ActiveRecord::Migration
  def self.up
    create_table "geo_states" do |t|
      t.string "name", :limit => 21
      t.string "abbreviation", :limit => 2
      t.boolean "requires_race"
      t.boolean "requires_party"
      t.timestamps
    end

    create_table "state_localizations" do |t|
      t.integer "state_id"
      t.string "locale", :limit => 2
      t.string "parties"
      t.timestamps
    end
  end

  def self.down
    drop_table "state_localizations"
    drop_table "geo_states"
  end
end
