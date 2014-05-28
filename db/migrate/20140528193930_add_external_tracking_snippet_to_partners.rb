class AddExternalTrackingSnippetToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :external_tracking_snippet, :text
  end
end
