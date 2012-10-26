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

  attr_accessor :tmp_asset_directory

  belongs_to :state, :class_name => "GeoState"
  belongs_to :government_partner_state, :class_name=> "GeoState"
  has_many :registrants

  has_attached_file :logo, PAPERCLIP_OPTIONS.merge(:styles => { :header => "75x45" })

  serialize :government_partner_zip_codes

  before_validation :reformat_phone
  before_validation :set_default_widget_image


  before_create :generate_api_key
  
  validate :check_valid_logo_url
  validate :government_partner_zip_specification

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

  validates_attachment_size :logo, :less_than => 1.megabyte, :message => "Logo must not be bigger than 1 megabyte"
  validates_attachment_content_type :logo, :message => "Logo must be a JPG, GIF, or PNG file",
                                    :content_type => ['image/jpeg', 'image/jpg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif']

  after_validation :make_paperclip_errors_readable

  include PartnerAssets
  
  named_scope :government, :conditions=>{:is_government_partner=>true}
  named_scope :standard, :conditions=>{:is_government_partner=>false}

  def self.find_by_login(login)
    p = find_by_username(login) || find_by_email(login)
    return (p && p.is_government_partner? ? nil : p)
  end

  def primary?
    self.id == DEFAULT_ID
  end
  
  def valid_api_key?(key)
    !key.blank? && !self.api_key.blank? && key == self.api_key
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
      { :state_name => GeoState[row["home_state_id"].to_i].name,
        :registrations_count => (c = row["registrations_count"].to_i),
        :registrations_percentage => c.to_f / sum
      }
    end
    named_counts.sort_by {|r| [-r[:registrations_count], r[:state_name]]}
  end

  def registration_stats_race
    counts = Registrant.connection.select_all(<<-"SQL")
      SELECT count(*) as registrations_count, race, locale FROM `registrants`
      WHERE (status = 'complete' OR status = 'step_5') AND partner_id = #{self.id}
      GROUP BY race
    SQL

    en_races = I18n.backend.send(:lookup, :en, "txt.registration.races")
    es_races = I18n.backend.send(:lookup, :es, "txt.registration.races")
    counts, es_counts = counts.partition { |row| row["locale"] == "en" || !es_races.include?(row["race"]) }
    counts.each do |row|
      if ( i = en_races.index(row["race"]) )
        race_name_es = es_races[i]
        es_row = nil
        es_counts.reject! {|r| es_row = r if r["race"] == race_name_es }
        row["registrations_count"] = row["registrations_count"].to_i + es_row["registrations_count"].to_i if es_row
      else
        row["race"] = "Unknown"
      end
    end
    es_counts.each do |row|
      row["race"] = en_races[ es_races.index(row["race"]) ]
      counts << row
    end

    sum = counts.sum {|row| row["registrations_count"].to_i}
    named_counts = counts.collect do |row|
      { :race => row["race"],
        :registrations_count => (c = row["registrations_count"].to_i),
        :registrations_percentage => c.to_f / sum
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

    male_titles = [I18n.backend.send(:lookup, :en, "txt.registration.titles")[0], I18n.backend.send(:lookup, :es, "txt.registration.titles")[0]]
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
    stats[:age_under_18]  = { :count => Registrant.count(:conditions => [conditions, self, 0, 17]) }
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
    stats[:day_count] =   Registrant.count(:conditions => [conditions, false, self, 1.day.ago])
    stats[:week_count] =  Registrant.count(:conditions => [conditions, false, self, 1.week.ago])
    stats[:month_count] = Registrant.count(:conditions => [conditions, false, self, 1.month.ago])
    stats[:year_count] =  Registrant.count(:conditions => [conditions, false, self, 1.year.ago])
    stats[:total_count] = Registrant.count(:conditions => ["finish_with_state = ? AND partner_id = ? AND (status = 'complete' OR status = 'step_5')", false, self])
    stats[:percent_complete] = stats[:total_count].to_f / Registrant.count(:conditions => ["finish_with_state = ? AND partner_id = ? AND (status != 'initial')", false, self])
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
      GROUP BY home_state_id
    SQL
    
    stats = {}
    
    [[:day_count, 1.day.ago],
     [:week_count, 1.week.ago],
     [:month_count, 1.month.ago],
     [:year_count, 1.year.ago],
     [:total_count, 1000.years.ago]].each do |range,time|
      counts = Registrant.connection.select_all(Registrant.send(:sanitize_sql_for_conditions, [sql, true, self, time]))
      counts.each do |row|
        state_name = GeoState[row["home_state_id"].to_i].name
        stats[state_name] ||= {:state_name=>state_name}
        stats[state_name][range] = row["registrations_count"].to_i
      end
    end
    stats.to_a.sort {|a,b| a[0]<=>b[0] }.collect{|a| a[1]}
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
      rescue
        logo_url_errors << "Could not download #{url} for logo"        
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
    Notifier.deliver_password_reset_instructions(self)
  end

  def generate_registrants_csv
    FasterCSV.generate do |csv|
      csv << Registrant::CSV_HEADER
      registrants.find_each(:batch_size=>500, :include => [:home_state, :mailing_state, :partner]) do |reg|
        csv << reg.to_csv_array
      end
    end
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
    app_css = File.expand_path(app_css)
    reg_css = File.expand_path(reg_css)
    part_css = File.expand_path(part_css)

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

    # if !File.exists?(app_css)
    #   raise "File '#{app_css}' not found"
    # end
    # if !File.exists?(reg_css)
    #   raise "File '#{reg_css}' not found"
    # end

    if partner.any_css_present?
      raise "Partner '#{partner_id}' has assets. Try running 'rake partner:enable_whitelabel #{partner_id}'"
    end


    unless File.directory?(partner.assets_path)
      unless Dir.mkdir(partner.assets_path)
        raise "Asset directory #{partner.assets_path} could not be created."
      end
    end

    FileUtils.cp(app_css, partner.absolute_application_css_path) if File.exists?(app_css)
    FileUtils.cp(reg_css, partner.absolute_registration_css_path) if File.exists?(reg_css)
    FileUtils.cp(part_css, partner.absolute_partner_css_path) if File.exists?(part_css)

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
  
  
protected
  def check_valid_logo_url
    logo_url_errors.each do |message|
      self.errors.add(:logo_image_URL, message)
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

  def random_key
    Digest::SHA1.hexdigest([Time.now, (1..10).map { rand.to_s}].join('--'))
  end

end
