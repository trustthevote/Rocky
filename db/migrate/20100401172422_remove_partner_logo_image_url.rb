class RemovePartnerLogoImageUrl < ActiveRecord::Migration
  def self.up
    remove_column "partners", "logo_image_url"
  end

  def self.down
    add_column "partners", "logo_image_url", :string
  end
end
