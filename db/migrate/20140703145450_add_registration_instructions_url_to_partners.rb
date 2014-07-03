class AddRegistrationInstructionsUrlToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :registration_instructions_url, :string
  end
end
