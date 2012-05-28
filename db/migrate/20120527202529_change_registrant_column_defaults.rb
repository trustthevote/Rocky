class ChangeRegistrantColumnDefaults < ActiveRecord::Migration
  def self.up
    change_column_default :registrants, :opt_in_email, false
    change_column_default :registrants, :volunteer, false
  end

  def self.down
    change_column_default :registrants, :opt_in_email, nil
    change_column_default :registrants, :volunteer, nil
  end
end
