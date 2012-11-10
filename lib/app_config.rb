class AppConfig
  
  cattr_accessor :widget_loader_url
  cattr_accessor :hours_before_first_reminder, :hours_between_first_and_second_reminder, :pdf_expiration_days
  cattr_accessor :partner_csv_expiration_minutes
  
  def self.config_file_name
    "app_config.yml"
  end
  def self.config_file_path
    File.join(RAILS_ROOT, "config", config_file_name)
  end
  
  def self.widget_loader_url
    load_config if @@widget_loader_url.blank?
    @@widget_loader_url
  end
    
  def self.hours_before_first_reminder
    load_config if @@hours_before_first_reminder.blank?
    @@hours_before_first_reminder = 24 if @@hours_before_first_reminder.blank?
    @@hours_before_first_reminder.to_f.hours
  end
  def self.hours_between_first_and_second_reminder
    load_config if @@hours_between_first_and_second_reminder.blank?
    @@hours_between_first_and_second_reminder = 24 if @@hours_between_first_and_second_reminder.blank?
    @@hours_between_first_and_second_reminder.to_f.hours
  end
  def self.pdf_expiration_days
    load_config if @@pdf_expiration_days.blank?
    @@pdf_expiration_days = 14 if @@pdf_expiration_days.blank?
    @@pdf_expiration_days.to_f.days
  end

  def self.partner_csv_expiration_minutes
    load_config if @@partner_csv_expiration_minutes.blank?
    @@partner_csv_expiration_minutes = 30 if @@partner_csv_expiration_minutes.blank?
    @@partner_csv_expiration_minutes.to_f.minutes
  end
    
    
protected
  def self.load_config
    File.open(config_file_path, "r") do |f|
      config = YAML.load(f)
      @@widget_loader_url = config["widget_loader_url"]

      @@hours_before_first_reminder = config["hours_before_first_reminder"]
      @@hours_between_first_and_second_reminder= config["hours_between_first_and_second_reminder"]
      @@pdf_expiration_days= config["pdf_expiration_days"]

      @@partner_csv_expiration_minutes= config["partner_csv_expiration_minutes"]
    end
  end
end