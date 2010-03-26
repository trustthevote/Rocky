class AddWidgetImageToPartners < ActiveRecord::Migration
  def self.up
    add_column "partners", "widget_image", :string
  end

  def self.down
    remove_column "partners", "widget_image"
  end
end
