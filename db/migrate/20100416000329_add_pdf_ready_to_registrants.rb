class AddPdfReadyToRegistrants < ActiveRecord::Migration
  def self.up
    add_column "registrants", "pdf_ready", :boolean
  end

  def self.down
    remove_column "registrants", "pdf_ready"
  end
end
