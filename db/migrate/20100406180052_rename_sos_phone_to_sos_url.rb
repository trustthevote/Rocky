class RenameSosPhoneToSosUrl < ActiveRecord::Migration
  def self.up
    add_column "geo_states", "registrar_url", :string
  end

  def self.down
    remove_column "geo_states", "registrar_url"
  end
end
