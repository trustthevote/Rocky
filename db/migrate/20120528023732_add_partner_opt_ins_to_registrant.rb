class AddPartnerOptInsToRegistrant < ActiveRecord::Migration
  def self.up
    add_column :registrants, :partner_opt_in_email, :boolean, :default=>false
    add_column :registrants, :partner_opt_in_sms, :boolean, :default=>false
    add_column :registrants, :partner_volunteer, :boolean, :default=>false
    change_column_default :registrants, :opt_in_email, false
    change_column_default :registrants, :opt_in_sms, false
    change_column_default :registrants, :volunteer, false
  end

  def self.down
    remove_column :registrants, :partner_opt_in_email
    remove_column :registrants, :partner_opt_in_sms
    remove_column :registrants, :partner_volunteer
    change_column_default :registrants, :opt_in_email, nil
    change_column_default :registrants, :opt_in_sms, nil
    change_column_default :registrants, :volunteer, nil
  end
end
