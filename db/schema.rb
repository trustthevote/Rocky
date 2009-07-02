# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090629205052) do

  create_table "registrants", :force => true do |t|
    t.string   "status"
    t.string   "name_title"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "name_suffix"
    t.string   "email_address"
    t.date     "date_of_birth"
    t.boolean  "us_citizen"
    t.string   "phone"
    t.string   "phone_type"
    t.string   "home_address"
    t.string   "home_address2"
    t.string   "home_city"
    t.string   "home_state"
    t.string   "home_zip_code",    :limit => 9
    t.string   "mailing_address"
    t.string   "mailing_address2"
    t.string   "mailing_city"
    t.string   "mailing_state"
    t.string   "mailing_zip_code", :limit => 9
    t.boolean  "opt_in_sms"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
