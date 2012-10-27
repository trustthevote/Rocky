class AddCsvFileNameToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :csv_file_name, :string
  end

  def self.down
    remove_column :partners, :csv_file_name
  end
end
