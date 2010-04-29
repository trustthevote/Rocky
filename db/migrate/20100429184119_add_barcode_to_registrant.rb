class AddBarcodeToRegistrant < ActiveRecord::Migration
  def self.up
    add_column "registrants", "barcode", :string, :limit => 12
  end

  def self.down
    remove_column "registrants", "barcode"
  end
end
