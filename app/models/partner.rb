#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
require 'open-uri'

class Partner < ActiveRecord::Base
  acts_as_authentic
  

  DEFAULT_ID = 1

  WIDGET_GIFS = [
    "rtv-234x60-v1.gif",
    "rtv-234x60-v1-sp.gif",
    "rtv-234x60-v2.gif",
    "rtv-234x60-v3.gif",
    "rtv-234x60-v3_es.gif",
    "rtv-100x100-v1.gif",
    "rtv-100x100-v2.gif",
    "rtv-100x100-v2_es.gif",
    "rtv-100x100-v3.gif",
    "rtv-100x100-v3_es.gif",
    "rtv-180x150-v1.gif",
    "rtv-180x150-v1_es.gif",
    "rtv-180x150-v2.gif",
    "rtv-200x165-v1.gif",
    "rtv-200x165-v2.gif",
    "rtv-200x165-v2_es.gif",
    "rtv-300x100-v1.gif",
    "rtv-300x100-v2.gif",
    "rtv-300x100-v3.gif",
    "rtv-468x60-v1.gif",
    "rtv-468x60-v1-sp.gif",
    "rtv-468x60-v2.gif",
    "rtv-468x60-v2_es.gif",
    "rtv-468x60-v3.gif"
  ]

  WIDGET_IMAGES = WIDGET_GIFS.collect do |widget|
    widget =~ /-(\d+)x(\d+)-/
    size = "#{$1} x #{$2}"
    [widget, widget.gsub(/-|\.gif/,''), size]
  end
  DEFAULT_WIDGET_IMAGE_NAME = "rtv234x60v1"

  CSV_GENERATION_PRIORITY = Registrant::REMINDER_EMAIL_PRIORITY

  attr_accessor :tmp_asset_directory

  belongs_to :state, :class_name => "GeoState"
  belongs_to :government_partner_state, :class_name=> "GeoState"
  has_many :registrants

  def self.partner_assets_bucket
    if Rails.env.production?
      "rocky-partner-assets"
    else
      "rocky-partner-assets-#{Rails.env}"
    end
  end

  has_attached_file :logo, RockyConf.paperclip_options.to_hash.symbolize_keys.merge(:styles => { 
    :header => "75x45" 
  }).merge({
    fog_directory: partner_assets_bucket,
    fog_credentials: {
      provider: "AWS",
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  })
  
  def header_logo_url
    self.logo(:header)
  end
  
  def local_logo_original_dir
    Rails.root.join("public/system/logos/#{id}/original")
  end
  
  def upload_local_logo
    Dir.glob(local_logo_original_dir.join('*.*')).each do |fn|
      self.logo = File.open(fn)
      self.save!
    end
  end
  
  def self.sync_all_logos
    Partner.all.each do |p|
      p.upload_local_logo
    end
  end
  

  serialize :government_partner_zip_codes

  before_validation :reformat_phone
  before_validation :set_default_widget_image


  before_create :generate_api_key
  
  validate :check_valid_logo_url, :check_valid_partner_css_download_url
  validate :government_partner_zip_specification
  validate :check_valid_registration_instructions_url_format
  validates :registration_instructions_url, :url_format=>true
  
  after_save :write_partner_css_download_contents

  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :state_id
  validates_presence_of :state_abbrev, :message => "State can't be blank."
  validates_presence_of :zip_code
  validates_format_of :zip_code, :with => /^\d{5}(-\d{4})?$/, :allow_blank => true
  validates_presence_of :phone
  validates_format_of :phone, :with => /^\d{3}-\d{3}-\d{4}$/, :message => 'Phone must look like ###-###-####', :allow_blank => true
  validates_presence_of :organization


  validates_attachment :logo, 
    :size=>{:less_than => 1.megabyte, :message => "Logo must not be bigger than 1 megabyte"},
    :content_type=> { :message => "Logo must be a JPG, GIF, or PNG file",
                      :content_type => ['image/jpeg', 'image/jpg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'] }

  after_validation :make_paperclip_errors_readable

  serialize :survey_question_1, Hash
  serialize :survey_question_2, Hash
  serialize :pixel_tracking_codes, Hash
  
  
  # Need to declare attributes for each enabled lang
  RockyConf.enabled_locales.each do |locale|
    unless ['en', 'es'].include?(locale.to_s)
      locale = locale.underscore
      [1,2].each do |num|
        attr_accessor "survey_question_#{num}_#{locale}"
        define_method("survey_question_#{num}_#{locale}") do
          method_missing("survey_question_#{num}_#{locale}")
        end
        define_method("survey_question_#{num}_#{locale}=") do |val|
          method_missing("survey_question_#{num}_#{locale}=", val)
        end
      end
    end
  end
  
  # Need to declare attributes for each email type pixel tracker
  EmailTemplate::EMAIL_TYPES.each do |et|
    attr_accessor "#{et}_pixel_tracking_code"
    define_method("#{et}_pixel_tracking_code") do
      method_missing("#{et}_pixel_tracking_code")
    end
    define_method("#{et}_pixel_tracking_code=") do |val|
      method_missing("#{et}_pixel_tracking_code=", val)
    end
  end
  
  
  include PartnerAssets
  
  scope :government, where(:is_government_partner=>true)
  scope :standard, where(:is_government_partner=>false)

  def self.find_by_login(login)
    p = find_by_username(login) || find_by_email(login)
    return (p && p.is_government_partner? ? nil : p)
  end

  def primary?
    self.id == DEFAULT_ID
  end
  
  def self.primary_partner
    @@primary_partner ||= self.where(:id=>DEFAULT_ID).first
  end
  def primary_partner
    @primary_partner ||=  self.class.primary_partner
  end
  
  def primary_partner_api_key
    primary_partner ? primary_partner.api_key : nil
  end
  
  def valid_api_key?(key)
    !key.blank? && ((!self.api_key.blank? &&  key == self.api_key) || key == self.primary_partner_api_key)
  end

  def can_be_whitelabeled?
    !primary?
  end

  def custom_logo?
    !primary? && logo.file?
  end


  def registration_stats_state
    sql =<<-"SQL"
      SELECT count(*) as registrations_count, home_state_id FROM `registrants`
      WHERE (status = 'complete' OR status = 'step_5') 
        AND finish_with_state = ?
        AND partner_id = #{self.id}
      GROUP BY home_state_id
    SQL
    
    counts = Registrant.connection.select_all(Registrant.send(:sanitize_sql_for_conditions, [sql, false]))
    
    sum = counts.sum {|row| row["registrations_count"].to_i}
    named_counts = counts.collect do |row|
      state = GeoState[row["home_state_id"].to_i]
      { :state_name => state.nil? ? '' : state.name,
        :registrations_count => (c = row["registrations_count"].to_i),
        :registrations_percentage => c.to_f / sum
      }
    end
    named_counts.sort_by {|r| [-r[:registrations_count], r[:state_name]]}
  end

  #TODO: Fix for other languages
  def registration_stats_race
    counts = Registrant.connection.select_all(<<-"SQL")
      SELECT count(*) as registrations_count, race, locale FROM `registrants`
      WHERE (status = 'complete' OR status = 'step_5') AND partner_id = #{self.id}
      GROUP BY race
    SQL

    # take list of count/race/locale, substitute race/locale to all be en, group again
    en_counts = counts.collect do |crl|
      if crl["locale"] != 'en'
        crl['race'] = Registrant.english_race(crl['locale'], crl['race'])
      end
      crl['race'] = "Unknown" if crl['race'].blank?
      crl
    end
    race_counts = {}
    sum = 0
    en_counts.each do |crl|
      race_counts[crl['race']] ||= 0
      sum += crl['registrations_count'].to_i
      race_counts[crl['race']] +=  crl['registrations_count'].to_i
    end
    named_counts = []
    race_counts.each do |k,v|
      named_counts << {
        :race => k,
        :registrations_count => v,
        :registrations_percentage => v.to_f / sum
      }
    end

    named_counts.sort_by {|r| [-r[:registrations_count], r[:race]]}
  end

  def registration_stats_gender
    counts = Registrant.connection.select_all(<<-"SQL")
      SELECT count(*) as registrations_count, name_title FROM `registrants`
      WHERE (status = 'complete' OR status = 'step_5') AND partner_id = #{self.id}
      GROUP BY name_title
    SQL

    male_titles = RockyConf.enabled_locales.collect { |loc|
     I18n.backend.send(:lookup, loc, "txt.registration.titles.#{Registrant::TITLE_KEYS[0]}") 
    }.flatten.uniq
    
    male_count = female_count = 0

    counts.each do |row|
      if male_titles.include?(row["name_title"])
        male_count += row["registrations_count"].to_i
      else
        female_count += row["registrations_count"].to_i
      end
    end

    sum = male_count + female_count
    [ { :gender => "Male",
        :registrations_count => male_count,
        :registrations_percentage => male_count.to_f / sum
      },
      { :gender => "Female",
        :registrations_count => female_count,
        :registrations_percentage => female_count.to_f / sum
      }
    ].sort_by { |r| [ -r[:registrations_count], r[:gender] ] }
  end

  def registration_stats_age
    conditions = "partner_id = ? AND (status = 'complete' OR status = 'step_5') AND (age BETWEEN ? AND ?)"
    stats = {}
    stats[:age_under_18]  = { :count => Registrant.where([conditions, self, 0 , 17]).count }
    stats[:age_18_to_29]  = { :count => Registrant.count(:conditions => [conditions, self, 18, 29]) }
    stats[:age_30_to_39]  = { :count => Registrant.count(:conditions => [conditions, self, 30, 39]) }
    stats[:age_40_to_64]  = { :count => Registrant.count(:conditions => [conditions, self, 40, 64]) }
    stats[:age_65_and_up] = { :count => Registrant.count(:conditions => [conditions, self, 65, 199]) }
    total_count = stats.inject(0) {|sum, (key,stat)| sum + stat[:count]}
    stats.each { |key, stat| stat[:percentage] = percentage(stat[:count], total_count) }
    stats
  end

  def registration_stats_party
    sql = <<-SQL
      SELECT official_party_name, count(registrants.id) AS registrants_count FROM registrants
      INNER JOIN geo_states ON geo_states.id = registrants.home_state_id
      WHERE registrants.partner_id = #{self.id}
        AND (status = 'complete' OR status = 'step_5')
      GROUP BY official_party_name
      ORDER BY registrants_count DESC, official_party_name
    SQL
    
    stats = self.class.connection.select_all(sql)
    total_count = stats.inject(0) { |sum, row| sum + row['registrants_count'].to_i }
    stats.collect do |row|
      { :party => row['official_party_name'],
        :count => row['registrants_count'].to_i,
        :percentage => percentage(row['registrants_count'], total_count)
      }
    end
  end

  def percentage(count, total_count)
    total_count > 0 ? count.to_f / total_count : 0.0
  end

  def registration_stats_completion_date
    conditions = "finish_with_state = ? AND partner_id = ? AND (status = 'complete' OR status = 'step_5') AND created_at >= ?"
    stats = {}
    stats[:day_count] = {:completed => Registrant.count(:conditions => [conditions, false, self, 1.day.ago]) }
    stats[:week_count] = {:completed => Registrant.count(:conditions => [conditions, false, self, 1.week.ago]) }
    stats[:month_count] = {:completed => Registrant.count(:conditions => [conditions, false, self, 1.month.ago]) }
    stats[:year_count] =  {:completed => Registrant.count(:conditions => [conditions, false, self, 1.year.ago]) }
    stats[:total_count] = {:completed => Registrant.count(:conditions => ["finish_with_state = ? AND partner_id = ? AND (status = 'complete' OR status = 'step_5')", false, self]) }
    stats[:percent_complete] = {:completed => stats[:total_count][:completed].to_f / Registrant.count(:conditions => ["finish_with_state = ? AND partner_id = ? AND (status != 'initial')", false, self]) }
    
    conditions = "finish_with_state = ? AND partner_id = ? AND (status = 'complete' OR status = 'step_5') AND created_at >= ? AND pdf_downloaded = ?"

    stats[:day_count][:downloaded] = Registrant.count(:conditions => [conditions, false, self, 1.day.ago, true])
    stats[:week_count][:downloaded] = Registrant.count(:conditions => [conditions, false, self, 1.week.ago, true])
    stats[:month_count][:downloaded] = Registrant.count(:conditions => [conditions, false, self, 1.month.ago, true])
    stats[:year_count][:downloaded] = Registrant.count(:conditions => [conditions, false, self, 1.year.ago, true])
    stats[:total_count][:downloaded] = Registrant.count(:conditions => ["finish_with_state = ? AND partner_id = ? AND (status = 'complete' OR status = 'step_5') AND pdf_downloaded = ?", false, self, true])
    stats[:percent_complete][:downloaded] = stats[:total_count][:downloaded].to_f / Registrant.count(:conditions => ["finish_with_state = ? AND partner_id = ? AND (status != 'initial')", false, self])


    
    stats
  end
  
  def registration_stats_finish_with_state_completion_date
    #conditions = "finish_with_state = ? AND partner_id = ? AND status = 'complete' AND created_at >= ?"
    sql =<<-"SQL"
      SELECT count(*) as registrations_count, home_state_id FROM `registrants`
      WHERE status = 'complete'
        AND finish_with_state = ?
        AND partner_id = ?
        AND created_at >= ?
        AND home_state_id in (?)
      GROUP BY home_state_id
    SQL
    
    enabled_state_ids = GeoState.states_with_online_registration.collect{|abbr| GeoState[abbr].id }
    
    stats = {}
    
    [[:day_count, 1.day.ago],
     [:week_count, 1.week.ago],
     [:month_count, 1.month.ago],
     [:year_count, 1.year.ago],
     [:total_count, 1000.years.ago]].each do |range,time|
      counts = Registrant.connection.select_all(Registrant.send(:sanitize_sql_for_conditions, [sql, true, self, time, enabled_state_ids]))
      counts.each do |row|
        state_name = GeoState[row["home_state_id"].to_i].name
        stats[state_name] ||= {:state_name=>state_name}
        stats[state_name][range] = row["registrations_count"].to_i
      end
    end
    stats.to_a.sort {|a,b| a[0]<=>b[0] }.collect{|a| a[1]}
  end

  def ask_for_volunteers?
    RockyConf.sponsor.allow_ask_for_volunteers && read_attribute(:ask_for_volunteers)
  end

  def state_abbrev=(abbrev)
    self.state = GeoState[abbrev]
  end

  def state_abbrev
    state && state.abbreviation
  end
  
  def government_partner_state_abbrev=(abbrev)
    self.government_partner_state = GeoState[abbrev]
  end
  
  def government_partner_state_abbrev
    government_partner_state && government_partner_state.abbreviation
  end

  def government_partner_zip_code_list=(string_list)
    zips = []
    string_list.to_s.split(/[^-\d]/).each do |item|
      zip = item.strip.match(/^(\d{5}(-\d{4})?)$/).to_s
      zips << zip unless zip.blank?
    end
    self.government_partner_zip_codes = zips
  end
  
  def government_partner_zip_code_list
    government_partner_zip_codes ? government_partner_zip_codes.join("\n") : nil
  end


  def logo_url
    @logo_url
  end
  
  def logo_url_errors
    @logo_url_errors ||= []
  end
  
  def logo_url=(url)
    @logo_url=url
    if !(url=~/^http:\/\//)
      logo_url_errors << "Pleave provide an HTTP url"
    else
      begin
        io = open(url)
        def io.original_filename; base_uri.path.split('/').last; end
        raise 'No Filename' if io.original_filename.blank?
        self.logo = io
      rescue Exception=>e
        # puts e.message
        logo_url_errors << "Could not download #{url} for logo"        
      end
    end
  end
  
  def partner_css_download_url
    @partner_css_download_url
  end
  
  def partner_css_download_contents
    @partner_css_download_contents
  end
  
  def partner_css_download_url_errors
    @partner_css_download_url_errors ||= []
  end
  
  def partner_css_download_url=(url)
    @partner_css_download_url=url
    if !(url=~/^http:\/\//)
      partner_css_download_url_errors << "Pleave provide an HTTP url"
    else
      begin
        io = open(url)
        @partner_css_download_contents = io.read
        io.close
      rescue Exception=>e
        # puts e.message
        partner_css_download_url_errors << "Could not download #{url} for partner css"        
      end
    end
  end
  
  
  def generate_random_password
    self.password = random_key
    self.password_confirmation = self.password
  end

  def generate_username
    self.username = self.email
  end

  def generate_api_key!
    generate_api_key
    save!
  end

  def generate_api_key
    self.api_key = random_key
  end

  def reformat_phone
    if phone.present? && phone_changed?
      digits = phone.gsub(/\D/,'')
      if digits.length == 10
        self.phone = [digits[0..2], digits[3..5], digits[6..9]].join('-')
      end
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver
  end

  def generate_registrants_csv
    CSV.generate do |csv|
      csv << Registrant::CSV_HEADER
      registrants.find_each(:batch_size=>500, :include => [:home_state, :mailing_state, :partner]) do |reg|
        csv << reg.to_csv_array
      end
    end
  end
  
  def generate_registrants_csv_async
    self.update_attributes!(:csv_ready=>false)
    action = Delayed::PerformableMethod.new(self, :generate_registrants_csv_file, [])
    Delayed::Job.enqueue(action, CSV_GENERATION_PRIORITY, Time.now)
  end
  
  def generate_registrants_csv_file
    time_stamp = Time.now
    self.csv_file_name = self.generate_csv_file_name(time_stamp)
    file = File.open(csv_file_path, "w")
    file.write generate_registrants_csv.force_encoding 'utf-8'
    file.close
    self.csv_ready = true
    self.save!

    action = Delayed::PerformableMethod.new(self, :delete_registrants_csv_file, [])
    Delayed::Job.enqueue(action, CSV_GENERATION_PRIORITY, AppConfig.partner_csv_expiration_minutes.from_now)
  end
  
  def delete_registrants_csv_file
    if File.exists?(csv_file_path)
      File.delete(csv_file_path)
    end
  end
  
  def generate_csv_file_name(date_time)
    obfuscate = Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)}" )
    "csv-#{obfuscate}-#{date_time.strftime('%Y%m%d-%H%M%S')}.csv"
  end
  
  def csv_file_path
    File.join(csv_path, csv_file_name)
  end
  def csv_path
    path = File.join(Rails.root, "csv", self.id.to_s)
    FileUtils.mkdir_p(path)
    path
  end
  

  def widget_image_name
    WIDGET_IMAGES.detect { |widget| widget[0] == self.widget_image }[1]
  end

  def widget_image_name=(name)
    self.widget_image = WIDGET_IMAGES.detect { |widget| widget[1] == name }[0]
  end

  def set_default_widget_image
    self.widget_image_name = DEFAULT_WIDGET_IMAGE_NAME if self.widget_image.blank?
  end

  def make_paperclip_errors_readable
    if Array(errors[:logo]).any? {|e| e =~ /not recognized by the 'identify' command/}
      errors.clear
      errors.add(:logo, "logo must be an image file")
    end
  end

    

  def self.add_whitelabel(partner_id, app_css, reg_css, part_css)
    app_css = File.open(File.expand_path(app_css), "r")
    reg_css = File.open(File.expand_path(reg_css), "r")
    part_css = File.open(File.expand_path(part_css), "r")

    partner = nil
    begin
      partner = Partner.find(partner_id)
    rescue
    end

    raise "Partner with id '#{partner_id}' was not found." unless partner

    if partner.primary?
      raise "You can't whitelabel the primary partner."
    end

    if partner.whitelabeled
      raise "Partner '#{partner_id}' is already whitelabeled. Try running 'rake partner:upload_assets #{partner_id} #{app_css} #{reg_css}'"
    end


    if partner.any_css_present?
      raise "Partner '#{partner_id}' has assets. Try running 'rake partner:enable_whitelabel #{partner_id}'"
    end

    paf = PartnerAssetsFolder.new(partner)

    paf.update_css("application", app_css) if File.exists?(app_css)
    paf.update_css("registration", reg_css) if File.exists?(reg_css)
    paf.update_css("partner", part_css) if File.exists?(part_css)

    copy_success = partner.application_css_present? == File.exists?(app_css)
    copy_success = copy_success && partner.registration_css_present? == File.exists?(reg_css)
    copy_success = copy_success && partner.partner_css_present? == File.exists?(part_css)
    
    raise "Error copying css to partner directory '#{partner.assets_path}'" unless copy_success

    if copy_success
      partner.whitelabeled= true
      partner.save!
      return "Partner '#{partner_id}' has been whitelabeled. Place all asset files in\n#{partner.assets_path}"
    end

  end
  
  def default_pixel_tracking_code(kind)
    self.class.default_pixel_tracking_code(kind)
  end
  
  def self.default_pixel_tracking_code(kind)
    ea = kind
    ea = 'state_integrated' if ea == 'thank_you_external'
    ea = 'chase' if ea == 'chaser'
    return "<img src=\"http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=<%= @registrant.uid %>&t=event&ec=email&ea=#{ea}_open&el=<%= @registrant.partner_id %>&cs=reminder&cm=email&cn=ovr_email_opens&cm1=1&ul=<%= @registrant.locale %>\" />"
    
  end
  
  
protected


  def method_missing(method_name, *args, &block)
    if method_name =~ /^survey_question_(\d+)_([^=]+)(=?)$/
      question_num = $1
      locale = $2.to_s.underscore
      setter = !($3.blank?)
      if setter 
        if args.size == 1
          current = self.send("survey_question_#{question_num}")
          current[locale] = args[0]
          self.send("survey_question_#{question_num}=",current)
        else
          raise ArgumentError.new("Setting a survey question must have a value")
        end
      else
        return self.send("survey_question_#{question_num}")[locale]
      end
    elsif method_name =~ /^(.+)_pixel_tracking_code(=?)$/
      email_type = $1.to_s
      setter = !($2.blank?)
      if setter
        if args.size == 1
          self.pixel_tracking_codes[email_type] = args[0]
        else
          raise ArgumentError.new("Setting a pixel tracking code must have 1 argument")
        end
      else
        return self.pixel_tracking_codes[email_type]
      end
    else
      return super 
    end
  end

  def check_valid_logo_url
    logo_url_errors.each do |message|
      self.errors.add(:logo_image_URL, message)
    end
  end
  
  def check_valid_partner_css_download_url
    partner_css_download_url_errors.each do |message|
      self.errors.add(:partner_css_download_URL, message)
    end
  end
  
  def write_partner_css_download_contents
    if !partner_css_download_contents.blank?
      PartnerAssetsFolder.new(self).write_css("partner", partner_css_download_contents)
    end
  end
  
  def government_partner_zip_specification
    if self.is_government_partner? 
      [[self.government_partner_state.nil? && self.government_partner_zip_codes.blank?, 
            "Either a State or a list of zip codes must be specified for a government partner"],
       [!self.government_partner_state.nil? && !self.government_partner_zip_codes.blank?, 
            "Only one of State or zip code list can be specified for a government partner"]].each do |causes_error, message|
        if causes_error
          [:government_partner_state_abbrev, :government_partner_zip_code_list].each do |field|
            errors.add(field, message)
          end
        end         
      end
    end
  end

  def check_valid_registration_instructions_url_format
    if !registration_instructions_url.blank?
      if !(registration_instructions_url =~ /<STATE>/)
        errors.add(:registration_instructions_url, "must include <STATE> substitution variable")
      end
      if !(registration_instructions_url =~ /<LOCALE>/)
        errors.add(:registration_instructions_url, "must include <LOCALE> substitution variable")
      end
    end
    return true
  end
  
  def random_key
    Digest::SHA1.hexdigest([Time.now, (1..10).map { rand.to_s}].join('--'))
  end

end
