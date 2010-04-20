class AddOfficialPartyNameToRegistrants < ActiveRecord::Migration
  def self.up
    add_column "registrants", "official_party_name", :string
    add_index  "registrants", "official_party_name"
  end

  def self.down
    remove_index  "registrants", "official_party_name"
    remove_column "registrants", "official_party_name"
  end
end
