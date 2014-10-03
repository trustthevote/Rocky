class ZipCodeCountyAddress < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :geo_state
  
  validates_uniqueness_of :zip
  validates_presence_of :zip, :address, :geo_state_id
end
