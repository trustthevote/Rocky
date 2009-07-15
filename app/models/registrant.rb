class Registrant < ActiveRecord::Base
  include AASM

  STEPS = [:initial, :step_1, :step_2, :step_3, :complete]
  # TODO: add :es to get full set for validation
  TITLES = I18n.t('txt.registration.titles', :locale => :en)
  SUFFIXES = I18n.t('txt.registration.suffixes', :locale => :en)
  PARTIES = [ "American Co-dependent", "Birthday", "Republicratic", "Sub-genius", "Suprise" ]

  attr_protected :status

  aasm_column :status
  aasm_initial_state :initial
  aasm_state :initial
  aasm_state :step_1
  aasm_state :step_2
  aasm_state :step_3
  aasm_state :complete

  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  belongs_to :prev_state,    :class_name => "GeoState"

  has_many :localizations, :through => :home_state, :class_name => 'StateLocalization' do
    def by_locale(loc)
      find_by_locale(loc.to_s)
    end
  end

  delegate :requires_race?, :requires_party?, :to => :home_state, :allow_nil => true

  before_validation :set_home_state_from_zip_code
  before_validation :clear_mailing_address_unless_checked
  before_validation :clear_party_unless_required

  with_options :if => :at_least_step_1? do |reg|
    reg.validates_inclusion_of :locale, :in => %w(en es)
    reg.validates_presence_of :email_address
    reg.validates_presence_of :home_zip_code
    reg.validates_presence_of :date_of_birth
    reg.validates_acceptance_of :us_citizen, :accept => true
    reg.validates_presence_of :home_state_id
  end

  with_options :if => :at_least_step_2? do |reg|
    reg.validates_inclusion_of :name_title, :in => TITLES
    reg.validates_presence_of :first_name
    reg.validates_presence_of :last_name
    reg.validates_inclusion_of :name_suffix, :in => SUFFIXES, :allow_blank => true
    reg.validates_presence_of :home_address
    reg.validates_presence_of :home_city
    reg.validate :validate_race
    reg.validate :validate_party
  end

  def self.transition_if_ineligible(event)
    event.send(:transitions, :to => :ineligible, :from => Registrant::STEPS, :guard => :check_ineligible?)
  end

  aasm_event :advance_to_step_1 do
    Registrant.transition_if_ineligible(self)
    transitions :to => :step_1, :from => [:initial]
  end

  aasm_event :advance_to_step_2 do
    Registrant.transition_if_ineligible(self)
    transitions :to => :step_2, :from => [:step_1]
  end

  ### instance methods

  def has_mailing_address=(has_mailing_address)
    @has_mailing_address = !!(/^1|true$/i =~ has_mailing_address) # yes, we need a boolean
  end

  def has_mailing_address
    @has_mailing_address
  end
  alias_method :has_mailing_address?, :has_mailing_address

  def at_least_step_1?
    at_least_step?(1)
  end

  def at_least_step_2?
    at_least_step?(2)
  end

  def set_home_state_from_zip_code
    self.home_state = home_zip_code && (home_zip_code.to_i.even? ? GeoState['CA'] : GeoState['PA'])
  end

  def clear_mailing_address_unless_checked
    unless has_mailing_address?
      self.mailing_address = nil
      self.mailing_address2 = nil
      self.mailing_city = nil
      self.mailing_state = nil
      self.mailing_zip_code = nil
    end
  end

  def clear_party_unless_required
    self.party = nil unless requires_party?
  end

  def validate_race
    if requires_race?
      errors.add(:race, :inclusion) unless I18n.t('txt.registration.races').include?(race)
    end
  end

  def state_parties
    if requires_party?
      localizations.by_locale(locale).parties
    else
      nil
    end
  end

  def validate_party
    if requires_party?
      errors.add(:party, :inclusion) unless state_parties.include?(party)
    end
  end

  # def advance_to!(next_step, new_attributes = {})
  #   self.attributes = new_attributes
  #   current_status_number = STEPS.index(aasm_current_state)
  #   next_status_number = STEPS.index(next_step)
  #   status_number = [current_status_number, next_status_number].max
  #   send("advance_to_#{STEPS[status_number]}!")
  # end



  # %w(home mailing).each do |location|
  #   validates_presence_of "#{location}_address"
  #   validates_presence_of "#{location}_city"
  #   validates_presence_of "#{location}_state"
  # end

  def home_state_name
    home_state && home_state.name
  end

  def mailing_state_abbrev=(abbrev)
    self.mailing_state = GeoState[abbrev]
  end

  def mailing_state_abbrev
    mailing_state && mailing_state.abbreviation
  end

  def prev_state_abbrev=(abbrev)
    self.prev_state = GeoState[abbrev]
  end

  def prev_state_abbrev
    prev_state && prev_state.abbreviation
  end

  private

  def at_least_step?(step)
    STEPS.index(aasm_current_state) >= step
  end

  def check_ineligible?
    false # TODO: check eligiblity for reals
  end

end
