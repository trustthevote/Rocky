class Registrant < ActiveRecord::Base
  include AASM
  include Mergable

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
      find_by_locale(loc.to_s) || StateLocalization.find_by_state_id_and_locale(GeoState['CA'].id, loc.to_s) # TODO remove when we have localizations for all states
    end
  end

  delegate :requires_race?, :requires_party?, :to => :home_state, :allow_nil => true

  before_validation :set_home_state_from_zip_code
  before_validation :clear_superfluous_fields

  with_options :if => :at_least_step_1? do |reg|
    reg.validates_presence_of :partner_id
    reg.validates_inclusion_of :locale, :in => %w(en es)
    reg.validates_presence_of :email_address
    reg.validates_format_of :email_address, :with => Authlogic::Regex.email, :allow_blank => true
    reg.validates_presence_of :home_zip_code
    # reg.validate :zip_code_exists   # TODO
    reg.validates_presence_of :date_of_birth
    reg.validate :validate_age
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
    reg.validates_inclusion_of :race, :in => I18n.t('txt.registration.races'), :if => lambda { |reg| reg.all? :at_least_step_2?, :requires_race? }
    reg.validate :validate_party
    needs_mailing_address = lambda { |reg| reg.all? :at_least_step_2?, :has_mailing_address? }
    reg.validates_presence_of :mailing_address, :if => needs_mailing_address
    reg.validates_presence_of :mailing_city, :if => needs_mailing_address
    reg.validates_presence_of :mailing_state_id, :if => needs_mailing_address
    reg.validates_presence_of :mailing_zip_code, :if => needs_mailing_address
  end

  with_options :if => :at_least_step_3? do |reg|
    reg.validates_presence_of :state_id_number
    needs_prev_name = lambda { |reg| reg.all? :at_least_step_3?, :change_of_name? }
    reg.validates_presence_of :prev_name_title, :if => needs_prev_name
    reg.validates_presence_of :prev_first_name, :if => needs_prev_name
    reg.validates_presence_of :prev_last_name, :if => needs_prev_name
    needs_prev_address = lambda { |reg| reg.all? :at_least_step_3?, :change_of_address? }
    reg.validates_presence_of :prev_address, :if => needs_prev_address
    reg.validates_presence_of :prev_city, :if => needs_prev_address
    reg.validates_presence_of :prev_state_id, :if => needs_prev_address
    reg.validates_presence_of :prev_zip_code, :if => needs_prev_address
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

  aasm_event :advance_to_step_3 do
    Registrant.transition_if_ineligible(self)
    transitions :to => :step_3, :from => [:step_2]
  end

  ### instance methods

  def all?(*methods)
    methods.all? { |m| self.send(m) }
  end

  def at_least_step_1?
    at_least_step?(1)
  end

  def at_least_step_2?
    at_least_step?(2)
  end

  def at_least_step_3?
    at_least_step?(3)
  end

  def set_home_state_from_zip_code
    return unless home_zip_code
    self.home_state = GeoState.for_zip_code(home_zip_code.strip)
  end

  def clear_superfluous_fields
    unless has_mailing_address?
      self.mailing_address = nil
      self.mailing_unit = nil
      self.mailing_city = nil
      self.mailing_state = nil
      self.mailing_zip_code = nil
    end
    unless change_of_name?
      self.prev_name_title = nil
      self.prev_first_name = nil
      self.prev_middle_name = nil
      self.prev_last_name = nil
      self.prev_name_suffix = nil
    end
    unless change_of_address?
      self.prev_address = nil
      self.prev_unit = nil
      self.prev_city = nil
      self.prev_state = nil
      self.prev_zip_code = nil
    end
  end

  def validate_age
    if date_of_birth
      errors.add(:date_of_birth, "You must be at least 16 years old") unless date_of_birth < 16.years.ago.to_date
    end
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
  
  def will_be_18_by_election?
    true
  end

  def pdf_date_of_birth
    "%d/%d/%d" % [date_of_birth.month, date_of_birth.mday, date_of_birth.year]
  end

  def generate_pdf!
    unless File.exists?(pdf_path)
      Tempfile.open("nvra-#{to_param}") do |f|
        f.puts to_xfdf
        f.close
        merge_pdf(f)
      end
    end
  end

  def merge_pdf(tmp)
    nvra_path = File.join(Rails.root, "data", "nvra_pg4.pdf")
    classpath = ["$CLASSPATH", File.join(Rails.root, "lib/pdf_merge/lib/iText-2.1.7.jar"), File.join(Rails.root, "lib/pdf_merge/out/production/Rocky_pdf")].join(":")
    `java -classpath #{classpath} PdfMerge #{nvra_path} #{tmp.path} #{pdf_path}`
  end

  def pdf_path
    FileUtils.mkdir_p(File.join(Rails.root, "public", "pdf"))
    File.join(Rails.root, "public", "pdf", "nvra-#{to_param}.pdf")
  end

  private

  def at_least_step?(step)
    STEPS.index(aasm_current_state) >= step
  end

  def check_ineligible?
    false # TODO: check eligiblity for reals
  end

end
