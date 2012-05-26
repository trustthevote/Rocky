class CreateEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :email_templates do |t|
      t.integer :partner_id, :null => false
      t.string  :name, :null => false
      t.text    :body

      t.timestamps
    end

    add_index :email_templates, [ :partner_id, :name ], :unique => true
  end

  def self.down
    drop_table :email_templates
  end
end
