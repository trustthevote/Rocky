class CreatePdfGenerations < ActiveRecord::Migration
  def change
    create_table :pdf_generations do |t|
      t.integer :registrant_id
      t.boolean :locked, :default=>false
      t.timestamps
    end
    add_index :pdf_generations, :locked
  end
end
