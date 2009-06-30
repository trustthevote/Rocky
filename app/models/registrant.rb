class Registrant < ActiveRecord::Base
  include AASM
  aasm_column :status
  validates_presence_of :first_name
end
