class AddPdfDownloadedAtToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :pdf_downloaded_at, :datetime
  end
end
