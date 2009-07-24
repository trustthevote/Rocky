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

  # ZIP codes
  
  def self.read_zip_file(file_name)
    lines = File.new(File.join(Rails.root, "data/zip_codes/#{file_name}")).readlines
    Hash[*(lines.collect {|line| line.chomp.split(',')}.flatten)]
  end

  def self.zip5map
    @@zip5 ||= read_zip_file('zip5.csv')
  end

  def self.zip3map
    @@zip3 ||= read_zip_file('zip3.csv')
  end

  def self.for_zip_code(zip)
    self[ zip5map[zip[0,5]] || zip3map[zip[0,3]] ]
  end

end
