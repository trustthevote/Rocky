class AddUnder18FlagsToRegistrants < ActiveRecord::Migration
  def self.up
    remove_column "registrants", "ineligible_attest"
    add_column    "registrants", "under_18_ok", :boolean
    add_column    "registrants", "remind_when_18", :boolean
  end

  def self.down
    add_column    "registrants", "ineligible_attest", :boolean
    remove_column "registrants", "under_18_ok"
    remove_column "registrants", "remind_when_18"
  end
end
