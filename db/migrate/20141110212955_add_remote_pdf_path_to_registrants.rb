class AddRemotePdfPathToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :remote_pdf_path, :string
  end
end
