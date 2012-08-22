class AppConfig
  
  cattr_accessor :widget_loader_url
  
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
    
protected
  def self.load_config
    File.open(config_file_path, "r") do |f|
      config = YAML.load(f)
      @@widget_loader_url = config["widget_loader_url"]
    end
  end
end