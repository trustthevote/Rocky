class AddSubjectToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :subject, :string
  end
end
