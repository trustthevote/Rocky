class Registrant < ActiveRecord::Base

  class AbandonedRecord < StandardError
    attr_reader :registrant
    def initialize(registrant)
      @registrant = registrant
    end
  end


  include AASM
  include Mergable
  include Lolrus
  include ActionView::Helpers::UrlHelper

  STEPS = [:initial, :step_1, :step_2, :step_3, :step_4, :step_5]
  # TODO: add :es to get full set for validation
  TITLES = I18n.t('txt.registration.titles', :locale => :en) + I18n.t('txt.registration.titles', :locale => :es)
  SUFFIXES = I18n.t('txt.registration.suffixes', :locale => :en) + I18n.t('txt.registration.suffixes', :locale => :es)
  REMINDER_EMAILS_TO_SEND = 2
  STALE_TIMEOUT = 30.minutes

  CSV_HEADER = [
    "Status",
    "Language",
    "Date of birth",
    "Email address",
    "First registration?",
    "US citizen?",
    "Salutation",
    "First name",
    "Middle name",
    "Last name",
    "Name suffix",
    "Home address",
    "Home unit",
    "Home city",
    "Home state",
    "Home zip code",
    "Has mailing address?",
    "Mailing address",
    "Mailing unit",
    "Mailing city",
    "Mailing state",
    "Mailing zip code",
    "Party",
    "Race",
    "Phone",
    "Phone type",
    "Opt-in to email?",
    "Opt-in to sms?",
    "Survey answer 1",
    "Survey answer 2",
    "Volunteer",
    "Ineligible reason",
    "Started registration"
  ]

  attr_protected :status

  aasm_column :status
  aasm_initial_state :initial
  STEPS.each { |step| aasm_state step }
  aasm_state :complete, :enter => :complete_registration
  aasm_state :under_18
  aasm_state :rejected

  belongs_to :partner
  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  belongs_to :prev_state,    :class_name => "GeoState"

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

  before_validation :clear_superfluous_fields
  before_validation :reformat_state_id_number
  before_validation :reformat_phone

  after_validation :calculate_age
  after_validation :set_official_party_name
  after_validation :check_ineligible
  after_validation :enqueue_tell_friends_emails

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
    reg.validates_format_of :state_id_number, :with => /^(none|\d{4}|[-*A-Z0-9]{7,42})$/i, :allow_blank => true
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

  attr_accessor :telling_friends
  with_options :if => :telling_friends do |reg|
    reg.validates_presence_of :tell_from
    reg.validates_presence_of :tell_email
    reg.validates_format_of :tell_email, :with => Authlogic::Regex.email
    reg.validates_presence_of :tell_recipients
    reg.validates_presence_of :tell_subject
    reg.validates_presence_of :tell_message
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
    transitions :to => :step_1, :from => [:initial, :step_1, :step_2, :step_3, :step_4, :rejected]
  end
  
  aasm_event :advance_to_step_2 do
    transitions :to => :step_2, :from => [:step_1, :step_2, :step_3, :step_4, :rejected]
  end

  aasm_event :advance_to_step_3 do
    transitions :to => :step_3, :from => [:step_2, :step_3, :step_4, :rejected]
  end

  aasm_event :advance_to_step_4 do
    transitions :to => :step_4, :from => [:step_3, :step_4, :rejected]
  end

  aasm_event :advance_to_step_5 do
    transitions :to => :step_5, :from => [:step_4, :rejected]
  end

  aasm_event :complete do
    transitions :to => :complete, :from => [:step_5]
  end

  aasm_event :request_reminder do
    transitions :to => :under_18, :from => [:rejected]
  end

  def self.find_by_param(param)
    reg = find_by_uid(param)
    raise AbandonedRecord.new(reg) if reg && reg.abandoned?
    reg
  end

  def self.find_by_param!(param)
    find_by_param(param) || begin raise ActiveRecord::RecordNotFound end
  end

  def self.abandon_stale_records
    stale = self.find(:all, :conditions => ["(NOT abandoned) AND (status != 'complete') AND (updated_at < ?)", STALE_TIMEOUT.seconds.ago])
    stale.each do |reg|
      reg.abandon!
      Rails.logger.info "Registrant #{reg.id} abandoned at #{Time.now}"
    end
  end

  ### instance methods
  attr_accessor :attest_true

  def to_param
    uid
  end

  def localization
    @localization ||=
      home_state_id && locale &&
        StateLocalization.find(:first, :conditions => {:state_id  => home_state_id, :locale => locale})
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

  def reformat_state_id_number
    self.state_id_number.upcase! if self.state_id_number.present? && self.state_id_number_changed?
  end

  def reformat_phone
    if phone.present? && phone_changed?
      digits = phone.gsub(/\D/,'')
      if digits.length == 10
        self.phone = [digits[0..2], digits[3..5], digits[6..9]].join('-')
      end
    end
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

  def calculate_age
    if errors.on(:date_of_birth).blank?
      now = (created_at || Time.now).to_date
      years = now.year - date_of_birth.year
      if (date_of_birth.month > now.month) || (date_of_birth.month == now.month && date_of_birth.day > now.day)
        years -= 1
      end
      self.age = years
    else
      self.age = nil
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
      localization.parties + [localization.no_party]
    else
      nil
    end
  end

  def set_official_party_name
    return unless self.step_5? || self.complete?
    self.official_party_name =
      if party.blank?
        "None"
      else
        en_loc = StateLocalization.find(:first, :conditions => {:state_id  => home_state_id, :locale => "en"})
        case self.locale
          when "en"
            party == en_loc.no_party ? "None" : party
          when "es"
            es_loc = StateLocalization.find(:first, :conditions => {:state_id  => home_state_id, :locale => "es"})
            if party == es_loc.no_party
              "None"
            else
              en_loc[:parties][ es_loc[:parties].index(party) ]
            end
          end
      end
  end

  def state_id_tooltip
    localization.id_number_tooltip
  end

  def race_tooltip
    localization.race_tooltip
  end

  def party_tooltip
    localization.party_tooltip
  end

  def home_state_not_participating_text
    localization.not_participating_tooltip
  end

  def under_18_instructions_for_home_state
    I18n.t('txt.registration.instructions.under_18',
            :state_name => home_state.name,
            :state_rule => localization.sub_18)
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

  def abandon!
    self.attributes = {:abandoned => true, :state_id_number => nil}
    self.save(false)
  end

  # def advance_to!(next_step, new_attributes = {})
  #   self.attributes = new_attributes
  #   current_status_number = STEPS.index(aasm_current_state)
  #   next_status_number = STEPS.index(next_step)
  #   status_number = [current_status_number, next_status_number].max
  #   send("advance_to_#{STEPS[status_number]}!")
  # end

  def home_zip_code=(zip)
    self[:home_zip_code] = zip
    self.home_state = nil
    self[:home_state_id] = zip && (s = GeoState.for_zip_code(zip.strip)) && s.id
  end

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

  def form_date_of_birth
    if @raw_date_of_birth
      @raw_date_of_birth
    elsif date_of_birth
      "%d-%d-%d" % [date_of_birth.month, date_of_birth.mday, date_of_birth.year]
    else
      nil
    end
  end

  def wrap_up
    complete!
  end

  def complete_registration
    I18n.locale = self.locale.to_sym
    generate_pdf
    deliver_confirmation_email
    enqueue_reminder_emails
    redact_sensitive_data
  end

  def generate_pdf
    unless File.exists?(pdf_file_path)
      Tempfile.open("nvra-#{to_param}") do |f|
        f.puts to_xfdf
        f.close
        merge_pdf(f)
      end
    end
  end

  def deliver_confirmation_email
    Notifier.deliver_confirmation(self)
  end

  def enqueue_reminder_emails
    update_attributes(:reminders_left => REMINDER_EMAILS_TO_SEND)
    enqueue_reminder_email
  end

  def enqueue_reminder_email
    action = Delayed::PerformableMethod.new(self, :deliver_reminder_email, [])
    Delayed::Job.enqueue(action, 0, INTERVAL_BETWEEN_REMINDER_EMAILS.from_now)
  end

  def deliver_reminder_email
    if reminders_left > 0
      Notifier.deliver_reminder(self)
      update_attributes!(:reminders_left => reminders_left - 1)
      enqueue_reminder_email if reminders_left > 0
    end
  rescue StandardError => error
    HoptoadNotifier.notify(
      :error_class => error.class.name,
      :error_message => "DelayedJob Worker Error(#{error.class.name}): #{error.message}",
      :request => { :params => {:worker => "deliver_reminder_email", :registrant_id => self.id} })
  end
  
  def redact_sensitive_data
    self.state_id_number = nil
  end

  def merge_pdf(tmp)
    if File.exist?('tmp/pids/rocky_pdf_worker.pid')
      response = Net::HTTP.post_form(URI.parse('http://localhost:8080/pdfmerge/'),
                                     {'nvraTemplatePath'=> nvra_template_path, 'tmpPath'=> tmp.path, 'pdfFilePath' => pdf_file_path })
      raise "PDF merge failed with status #{response.code}" unless response.code == "200"
    else
      classpath = [
          "$CLASSPATH",
          File.join(Rails.root, "lib/pdf_merge/lib/iText-2.1.7.jar"),
          File.join(Rails.root, "lib/pdf_merge/lib/pdfmerge.jar")
        ].join(":")
      `java -classpath #{classpath} com.pivotallabs.rocky.PdfMerge #{nvra_template_path} #{tmp.path} #{pdf_file_path}`
    end
  end

  def nvra_template_path
    File.join(Rails.root, "data", "nvra_templates", "nvra_#{locale && locale.downcase}_#{home_state && home_state.abbreviation.downcase}.pdf")
  end

  def pdf_path
    "/pdf/#{bucket_code}/#{to_param}.pdf"
  end

  def pdf_file_path
    FileUtils.mkdir_p(File.join(Rails.root, "pdf", bucket_code))
    File.join(Rails.root, pdf_path)
  end

  def bucket_code
    super(self.created_at)
  end

  def check_ineligible
    self.ineligible_non_participating_state = home_state && !home_state.participating?
    self.ineligible_age = age && age < 18
    self.ineligible_non_citizen = !us_citizen?
    true # don't halt save in after_validation
  end

  def ineligible?
    ineligible_non_participating_state || (ineligible_age && !under_18_ok) || ineligible_non_citizen
  end

  def eligible?
    !ineligible?
  end

  def to_csv_array
    [
      status.humanize,
      locale == 'en' ? "English" : "Spanish",
      pdf_date_of_birth,
      email_address,
      yes_no(first_registration?),
      yes_no(us_citizen?),
      name_title,
      first_name,
      middle_name,
      last_name,
      name_suffix,
      home_address,
      home_unit,
      home_city,
      home_state && home_state.abbreviation,
      home_zip_code,
      yes_no(has_mailing_address?),
      mailing_address,
      mailing_unit,
      mailing_city,
      mailing_state_abbrev,
      mailing_zip_code,
      party,
      race,
      phone,
      phone_type,
      yes_no(opt_in_email?),
      yes_no(opt_in_sms?),
      survey_answer_1,
      survey_answer_2,
      yes_no(volunteer?),
      ineligible_reason,
      created_at && created_at.to_s(:month_day_year)
    ]
  end

  def status_text
    I18n.locale = self.locale.to_sym
    @status_text ||=
      CGI.escape(
        case self.status.to_sym
        when :complete, :step_5 ; I18n.t('txt.status_text.message')
        when :under_18 ; I18n.t('txt.status_text.under_18_message')
        else ""
        end
        )
  end

  ### tell-a-friend email

  attr_writer :tell_from, :tell_email, :tell_recipients, :tell_subject, :tell_message
  attr_accessor :tell_recipients, :tell_message

  def tell_from
    @tell_from ||= "#{first_name} #{last_name}"
  end

  def tell_email
    @tell_email ||= email_address
  end

  def tell_subject
    @tell_subject ||=
      case self.status.to_sym
      when :complete ; I18n.t('email.tell_friend.subject')
      when :under_18 ; I18n.t('email.tell_friend_under_18.subject')
      end
  end

  def enqueue_tell_friends_emails
    if @telling_friends && self.errors.blank?
        tell_params = {
          :tell_from       => self.tell_from,
          :tell_email      => self.tell_email,
          :tell_recipients => self.tell_recipients,
          :tell_subject    => self.tell_subject,
          :tell_message    => self.tell_message
        }
      self.class.send_later(:deliver_tell_friends_emails, tell_params)
    end
  end

  def self.deliver_tell_friends_emails(tell_params)
    tell_params[:tell_recipients].split(",").each do |recipient|
      Notifier.deliver_tell_friends(tell_params.merge(:tell_recipients => recipient))
    end
  end

  private ###

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

  def yes_no(attribute)
    attribute ? "Yes" : "No"
  end

  def ineligible_reason
    case
    when ineligible_non_citizen? then "Not a US citizen"
    when ineligible_non_participating_state? then "State doesn't participate"
    when ineligible_age? then "Not old enough to register"
    else nil
    end
  end
end
