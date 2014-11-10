class AddRemoteUidToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :remote_uid, :string
    add_index :registrants, :remote_uid
  end
end
