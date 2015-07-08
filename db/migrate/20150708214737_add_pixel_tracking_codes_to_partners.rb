class AddPixelTrackingCodesToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :pixel_tracking_codes, :text
  end
end
