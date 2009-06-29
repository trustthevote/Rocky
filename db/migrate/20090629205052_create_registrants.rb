class CreateRegistrants < ActiveRecord::Migration
  def self.up
    create_table "registrants" do |t|
      t.string      "name_prefix"
      t.string      "first_name"
      t.string      "middle_name"
      t.string      "last_name"
      t.string      "name_suffix"
      t.string      "email_address"
      t.date        "date_of_birth"
      t.string      "zip_code", :limit => 9
      t.timestamps
    end
  end

  def self.down
    drop_table "registrants"
  end
end
