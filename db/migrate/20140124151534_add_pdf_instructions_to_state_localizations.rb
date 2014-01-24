class AddPdfInstructionsToStateLocalizations < ActiveRecord::Migration
  def change
    add_column :state_localizations, :pdf_instructions, :string
  end
end
