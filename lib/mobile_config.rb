class MobileConfig
  
  cattr_accessor :redirect_url, :browsers
  
  def self.config_file_name
    "mobile.yml"
  end
  def self.config_file_path
    File.join(RAILS_ROOT, "config", config_file_name)
  end
  
  def self.redirect_url
    load_config if @@redirect_url.blank?
    @@redirect_url
  end
  
  def self.browsers
    load_config if @@browsers.blank?
    @@browsers
  end
  
protected
  def self.load_config
    File.open(config_file_path, "r") do |f|
      config = YAML.load(f)
      @@redirect_url = config["mobile_redirect_url"]
      @@browsers = config["mobile_browsers"]
    end
  end
  
end