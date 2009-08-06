class Registrant < ActiveRecord::Base
  include AASM
  include Mergable

  STEPS = [:initial, :step_1, :step_2, :step_3, :step_4, :step_5, :complete]
  # TODO: add :es to get full set for validation
  TITLES = I18n.t('txt.registration.titles', :locale => :en)
  SUFFIXES = I18n.t('txt.registration.suffixes', :locale => :en)
  PARTIES = [ "American Co-dependent", "Birthday", "Republicratic", "Sub-genius", "Suprise" ]

  attr_protected :status

  aasm_column :status
  aasm_initial_state :initial
  STEPS.each { |step| aasm_state step }
  aasm_state :rejected

  belongs_to :partner
  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  belongs_to :prev_state,    :class_name => "GeoState"

  has_many :localizations, :through => :home_state, :class_name => 'StateLocalization' do
    def by_locale(loc)
      find_by_locale(loc.to_s) || StateLocalization.find_by_state_id_and_locale(GeoState['CA'].id, loc.to_s) # TODO remove when we have localizations for all states
    end
  end

  delegate :requires_race?, :requires_party?, :to => :home_state, :allow_nil => true

  def self.validates_zip_code(*attr_names)
    configuration = { }
    configuration.update(attr_names.extract_options!)

    validates_presence_of(attr_names, configuration)
    validates_format_of(attr_names, configuration.merge(:with => /^\d{5}(-\d{4})?$/, :allow_blank => true));

    validates_each(attr_names, configuration) do |record, attr_name, value|
      if record.errors.on(attr_name).nil? && !GeoState.valid_zip_code?(record.send(attr_name))
        record.errors.add(attr_name, :invalid_zip, :default => configuration[:message], :value => value) 
      end
    end
  end

  before_validation :set_home_state_from_zip_code
  before_validation :clear_superfluous_fields
  
  after_validation :check_ineligible
  
  before_create :generate_uid

  with_options :if => :at_least_step_1? do |reg|
    reg.validates_presence_of :partner_id
    reg.validates_inclusion_of :locale, :in => %w(en es)
    reg.validates_presence_of :email_address
    reg.validates_format_of :email_address, :with => Authlogic::Regex.email, :allow_blank => true
    reg.validates_zip_code    :home_zip_code
    reg.validates_presence_of :home_state_id
    reg.validate :validate_date_of_birth
    reg.validates_inclusion_of :us_citizen, :in => [false, true]
  end

  with_options :if => :at_least_step_2? do |reg|
    reg.validates_presence_of :name_title
    reg.validates_inclusion_of :name_title, :in => TITLES, :allow_blank => true
    reg.validates_presence_of :first_name
    reg.validates_presence_of :last_name
    reg.validates_inclusion_of :name_suffix, :in => SUFFIXES, :allow_blank => true
    reg.validates_presence_of :home_address
    reg.validates_presence_of :home_city
    reg.validate :validate_race
    reg.validate :validate_party
  end
  with_options :if => :needs_mailing_address? do |reg|
    reg.validates_presence_of :mailing_address
    reg.validates_presence_of :mailing_city
    reg.validates_presence_of :mailing_state_id
    reg.validates_zip_code    :mailing_zip_code
  end

  with_options :if => :at_least_step_3? do |reg|
    reg.validates_presence_of :state_id_number
    reg.validates_format_of :phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, :allow_blank => true
    reg.validates_presence_of :phone_type, :if => :has_phone?
  end
  with_options :if => :needs_prev_name? do |reg|
    reg.validates_presence_of :prev_name_title
    reg.validates_presence_of :prev_first_name
    reg.validates_presence_of :prev_last_name
  end
  with_options :if => :needs_prev_address? do |reg|
    reg.validates_presence_of :prev_address
    reg.validates_presence_of :prev_city
    reg.validates_presence_of :prev_state_id
    reg.validates_zip_code    :prev_zip_code
  end

  with_options :if => :at_least_step_5? do |reg|
    reg.validates_acceptance_of :attest_true
  end

  def needs_mailing_address?
    at_least_step_2? && has_mailing_address?
  end

  def needs_prev_name?
    at_least_step_3? && change_of_name?
  end

  def needs_prev_address?
    at_least_step_3? && change_of_address?
  end

  aasm_event :save_or_reject do
    transitions :to => :rejected, :from => Registrant::STEPS, :guard => :ineligible?
    [:step_1, :step_2, :step_3, :step_4, :step_5].each do |step|
      transitions :to => step, :from => step
    end
  end

  aasm_event :advance_to_step_1 do
    transitions :to => :step_1, :from => [:initial, :step_1, :step_2, :step_3, :step_4, :step_5, :complete, :rejected]
  end
  
  aasm_event :advance_to_step_2 do
    transitions :to => :step_2, :from => [:step_1, :step_2, :step_3, :step_4, :step_5, :complete, :rejected]
  end

  aasm_event :advance_to_step_3 do
    transitions :to => :step_3, :from => [:step_2, :step_3, :step_4, :step_5, :complete, :rejected]
  end

  aasm_event :advance_to_step_4 do
    transitions :to => :step_4, :from => [:step_3, :step_4, :step_5, :complete, :rejected]
  end

  aasm_event :advance_to_step_5 do
    transitions :to => :step_5, :from => [:step_4, :step_5, :complete, :rejected]
  end
  
  def self.find_by_param(param)
    find_by_uid(param)
  end

  ### instance methods
  attr_accessor :attest_true
  
  def to_param
    uid
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

  def at_least_step_5?
    at_least_step?(5)
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
    # self.race = nil unless requires_race?
    self.party = nil unless requires_party?
  end

  def validate_date_of_birth
    return if date_of_birth_before_type_cast.is_a?(Date)
    if date_of_birth_before_type_cast.blank?
      errors.add(:date_of_birth, :blank)
    else
      @raw_date_of_birth = date_of_birth_before_type_cast
      date = nil
      if matches = date_of_birth_before_type_cast.match(/^(\d{1,2})\D+(\d{1,2})\D+(\d{4})$/)
        m,d,y = matches.captures
        date = Date.civil(y.to_i, m.to_i, d.to_i) rescue nil
      elsif matches = date_of_birth_before_type_cast.match(/^(\d{4})\D+(\d{1,2})\D+(\d{1,2})$/)
        y,m,d = matches.captures
        date = Date.civil(y.to_i, m.to_i, d.to_i) rescue nil
      end
      if date
        @raw_date_of_birth = nil
        self[:date_of_birth] = date
      else
        errors.add(:date_of_birth, :format)
      end
    end
  end

  def validate_race
    if requires_race?
      if race.blank?
        errors.add(:race, :blank)
      else
        errors.add(:race, :inclusion) unless I18n.t('txt.registration.races').include?(race)
      end
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
      if party.blank?
        errors.add(:party, :blank)
      else
        errors.add(:party, :inclusion) unless state_parties.include?(party)
      end
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

  def full_name
    [name_title, first_name, middle_name, last_name, name_suffix].compact.join(" ")
  end

  def prev_full_name
    [prev_name_title, prev_first_name, prev_middle_name, prev_last_name, prev_name_suffix].compact.join(" ")
  end

  def phone_and_type
    if phone.blank?
      I18n.t('txt.registration.not_given')
    else
      "#{phone} (#{phone_type})"
    end
  end

  def pdf_date_of_birth
    "%d/%d/%d" % [date_of_birth.month, date_of_birth.mday, date_of_birth.year]
  end

  def form_date_of_birth
    if @raw_date_of_birth
      @raw_date_of_birth
    elsif date_of_birth
      "%d-%d-%d" % [date_of_birth.month, date_of_birth.mday, date_of_birth.year]
    else
      nil
    end
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
    classpath = ["$CLASSPATH", File.join(Rails.root, "lib/pdf_merge/lib/iText-2.1.7.jar"), File.join(Rails.root, "lib/pdf_merge/out/production/Rocky_pdf")].join(":")
    `java -classpath #{classpath} PdfMerge #{nvra_template_path} #{tmp.path} #{pdf_path}`
  end
  
  def nvra_template_path
    File.join(Rails.root, "data", "nvra_templates", "nvra_#{locale && locale.downcase}_#{home_state && home_state.abbreviation.downcase}.pdf")
  end

  def pdf_path
    FileUtils.mkdir_p(File.join(Rails.root, "public", "pdf"))
    File.join(Rails.root, "public", "pdf", "nvra-#{to_param}.pdf")
  end

  def check_ineligible
    self.ineligible_non_participating_state = home_state && !home_state.participating?
    self.ineligible_age = date_of_birth && (date_of_birth > 16.years.ago.to_date)
    self.ineligible_non_citizen = !us_citizen?
    true # don't halt save in after_validation
  end

  def ineligible?
    ineligible_non_participating_state || ineligible_age || ineligible_non_citizen
  end

  def eligible?
    !ineligible?
  end

  private

  def at_least_step?(step)
    current_step = STEPS.index(aasm_current_state)
    current_step && (current_step >= step)
  end
  
  def has_phone?
    !phone.blank?
  end
  
  def generate_uid
    self.uid = Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{email_address} -- #{home_zip_code}" )
  end
end
