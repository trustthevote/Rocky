class AddOptInFieldsToPartner < ActiveRecord::Migration
  def self.up
    add_column :partners, :partner_ask_for_volunteers, :boolean, :default=>false
    add_column :partners, :rtv_email_opt_in, :boolean, :default=>true
    add_column :partners, :partner_email_opt_in, :boolean, :default=>false
    add_column :partners, :rtv_sms_opt_in, :boolean, :default=>true
    add_column :partners, :partner_sms_opt_in, :boolean, :default=>false
  end

  def self.down
    remove_column :partners, :partner_ask_for_volunteers
    remove_column :partners, :rtv_email_opt_in
    remove_column :partners, :partner_email_opt_in
    remove_column :partners, :rtv_sms_opt_in
    remove_column :partners, :partner_sms_opt_in
  end
end
