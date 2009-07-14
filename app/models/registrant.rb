class Registrant < ActiveRecord::Base
  include AASM

  STEPS = [:initial, :step_1, :step_2, :step_3, :complete]
  # TODO: add :es to get full set for validation
  TITLES = I18n.t('txt.registration.titles', :locale => :en)
  SUFFIXES = I18n.t('txt.registration.suffixes', :locale => :en)
  RACES = I18n.t('txt.registration.races', :locale => :en)
  PARTIES = [ "American Co-dependent", "Birthday", "Republicratic", "Sub-genius", "Suprise" ]

  attr_protected :status

  aasm_column :status
  aasm_initial_state :initial
  aasm_state :initial
  aasm_state :step_1
  aasm_state :step_2
  aasm_state :step_3
  aasm_state :complete

  before_validation :upcase_states
  before_validation :clear_mailing_address_unless_checked

  with_options :if => :at_least_step_1? do |reg|
    reg.validates_presence_of :email_address
    reg.validates_presence_of :home_zip_code
    reg.validates_presence_of :date_of_birth
    reg.validates_acceptance_of :us_citizen, :accept => true
  end

  with_options :if => :at_least_step_2? do |reg|
    reg.validates_inclusion_of :name_title, :in => TITLES
    reg.validates_presence_of :first_name
    reg.validates_presence_of :last_name
    reg.validates_inclusion_of :name_suffix, :in => SUFFIXES, :allow_blank => true
    reg.validates_presence_of :home_address
    reg.validates_presence_of :home_city
    reg.validates_presence_of :home_state
    reg.validates_format_of :home_state, :with => /[A-Z]{2}/
    reg.validates_inclusion_of :race, :in => RACES, :if => :state_requires_race?
    reg.validates_inclusion_of :party, :in => PARTIES, :if => :state_requires_party?
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

  def upcase_states
    home_state.upcase!    unless home_state.blank?
    mailing_state.upcase! unless mailing_state.blank?
    prev_state.upcase!    unless prev_state.blank?
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

  def state_requires_race?
    false
  end

  def state_requires_party?
    false
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

  private

  def at_least_step?(step)
    STEPS.index(aasm_current_state) >= step
  end

  def check_ineligible?
    false # TODO: check eligiblity for reals
  end

end
