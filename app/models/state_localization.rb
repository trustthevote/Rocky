class StateLocalization < ActiveRecord::Base
  serialize :parties
  belongs_to :state, :class_name => 'GeoState'
  validates_presence_of :locale
end
