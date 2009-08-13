class Partner < ActiveRecord::Base
  acts_as_authentic

  belongs_to :state, :class_name => "GeoState"
  has_many :registrants

  before_validation :reformat_phone

  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :state_id
  validates_presence_of :zip_code
  validates_format_of :zip_code, :with => /^\d{5}(-\d{4})?$/, :allow_blank => true
  validates_presence_of :phone
  validates_format_of :phone, :with => /^\d{3}-\d{3}-\d{4}$/, :message => 'Phone must look like ###-###-####', :allow_blank => true
  validates_presence_of :logo_image_url

  def self.find_by_login(login)
    find_by_username(login) || find_by_email(login)
  end

  def self.default_id
    1
  end

  def primary?
    self.id == self.class.default_id
  end

  def registration_stats_state
    counts = Registrant.connection.select_all(<<-"SQL")
      SELECT count(*) as registrations_count, home_state_id FROM `registrants`
      WHERE (status = 'complete' OR status = 'step_5') AND partner_id = #{self.id}
      GROUP BY home_state_id
    SQL
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

  def state_abbrev=(abbrev)
    self.state = GeoState[abbrev]
  end

  def state_abbrev
    state && state.abbreviation
  end

  def reformat_phone
    unless phone.blank?
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
      registrants.all(:include => [:home_state, :mailing_state]).each do |reg|
        csv << reg.to_csv_array
      end
    end
  end

end
