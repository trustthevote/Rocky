class AddCollectEmailAddressToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :collect_email_address, :string
  end
end
