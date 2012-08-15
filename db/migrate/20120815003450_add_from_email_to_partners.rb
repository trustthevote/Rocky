class AddFromEmailToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :from_email, :string
  end

  def self.down
    remove_column :partners, :from_email
  end
end
