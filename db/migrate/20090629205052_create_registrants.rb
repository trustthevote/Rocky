class CreateRegistrants < ActiveRecord::Migration
  def self.up
    create_table "registrants" do |t|
      t.string      "status"
      t.string      "name_title"
      t.string      "first_name"
      t.string      "middle_name"
      t.string      "last_name"
      t.string      "name_suffix"
      t.string      "email_address"
      t.date        "date_of_birth"
      t.boolean     "us_citizen"
      t.string      "phone"
      t.string      "phone_type"
      t.string      "home_address"
      t.string      "home_address2"
      t.string      "home_city"
      t.string      "home_state"
      t.string      "home_zip_code", :limit => 9
      t.string      "mailing_address"
      t.string      "mailing_address2"
      t.string      "mailing_city"
      t.string      "mailing_state"
      t.string      "mailing_zip_code", :limit => 9
      t.boolean     "opt_in_sms"
      t.timestamps
    end
  end

  def self.down
    drop_table "registrants"
  end
end
