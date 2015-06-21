class AddPdfDownloadedToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :pdf_downloaded, :boolean, :default=>false
  end
end
