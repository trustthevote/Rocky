class ZipCodeCountyAddress < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :geo_state
end
