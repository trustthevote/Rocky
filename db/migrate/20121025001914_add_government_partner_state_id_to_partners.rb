class AddGovernmentPartnerStateIdToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :government_partner_state_id, :integer
  end

  def self.down
    remove_column :partners, :government_partner_state_id
  end
end
