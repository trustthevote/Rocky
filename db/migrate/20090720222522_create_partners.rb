class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table "partners" do |t|
      t.string    "username",           :null => false
      t.string    "email",              :null => false
      t.string    "crypted_password",   :null => false
      t.string    "password_salt",      :null => false
      t.string    "persistence_token",  :null => false
      t.timestamps
    end
    add_index "partners", "username"
    add_index "partners", "email"
    add_index "partners", "persistence_token"
  end

  def self.down
    drop_table "partners"
  end
end
