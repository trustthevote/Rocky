class AddIndexesToRegistrantStats < ActiveRecord::Migration
  def self.up
    add_index "registrants", "partner_id"
    add_index "registrants", "status"
    add_index "registrants", "name_title"
    add_index "registrants", "home_state_id"
    add_index "registrants", "race"
    add_index "registrants", "age"
    add_index "registrants", "created_at"
  end

  def self.down
    remove_index "registrants", "created_at"
    remove_index "registrants", "age"
    remove_index "registrants", "race"
    remove_index "registrants", "home_state_id"
    remove_index "registrants", "name_title"
    remove_index "registrants", "status"
    remove_index "registrants", "partner_id"
  end
end
