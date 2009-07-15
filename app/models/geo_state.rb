class GeoState < ActiveRecord::Base

  has_many :localizations, :class_name => 'StateLocalization', :foreign_key => 'state_id'

  def self.[](abbrev)
    init_all_states
    @@all_states[abbrev]
  end
  
  def self.collection_for_select
    init_all_states
    @@all_states.map { |abbrev, state| [state.name, abbrev] }.sort
  end
  
  def self.init_all_states
    @@all_states ||= all.index_by(&:abbreviation)
  end

  def self.reset_all_states
    @@all_states = nil
  end
end
