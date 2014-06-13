class CreateZipCodeCountyAddresses < ActiveRecord::Migration
  def change
    create_table :zip_code_county_addresses do |t|
      t.integer :geo_state_id
      t.string :zip
      t.string :address
      t.string :county
      t.timestamps
    end
    add_index :zip_code_county_addresses, :geo_state_id
    add_index :zip_code_county_addresses, :zip
  end
end
