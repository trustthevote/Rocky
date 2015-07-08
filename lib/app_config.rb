class AppConfig
  
  def self.widget_loader_url
    RockyConf.widget_loader_url
  end
    
  def self.hours_before_first_reminder
    setting_with_default(:hours_before_first_reminder, 24).to_f.hours
  end
  def self.hours_between_first_and_second_reminder
    setting_with_default(:hours_between_first_and_second_reminder, 24).to_f.hours
  end
  def self.hours_between_second_and_final_reminder
    setting_with_default(:hours_between_second_and_final_reminder, 24).to_f.hours
  end

  def self.pdf_expiration_days
    setting_with_default(:pdf_expiration_days, 14).to_f.days
  end

  def self.pdf_no_email_expiration_minutes
    setting_with_default(:pdf_no_email_expiration_minutes, 10).to_f.minutes
  end

  def self.partner_csv_expiration_minutes
    setting_with_default(:partner_csv_expiration_minutes, 30).to_f.minutes
  end

  def self.setting_with_default(setting_name, default_value)
    RockyConf.send(setting_name).blank? ? default_value : RockyConf.send(setting_name)
  end
    
end