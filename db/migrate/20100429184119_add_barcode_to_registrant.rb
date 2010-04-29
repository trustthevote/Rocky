class AddBarcodeToRegistrant < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
    def pdf_barcode
      user_code = id.to_s(36).rjust(6, "0")
      "*RTV-#{user_code}*".upcase             ### assumes RTV deployment
    end
  end

  def self.up
    add_column "registrants", "barcode", :string
    Registrant.find_each do |r|
      r.update_attributes!(:barcode => r.pdf_barcode)
    end
  end

  def self.down
    remove_column "registrants", "barcode"
  end
end
