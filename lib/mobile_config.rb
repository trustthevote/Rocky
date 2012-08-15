class MobileConfig
  
  cattr_accessor :redirect_url, :browsers
  
  def self.config_file_name
    "mobile.yml"
  end
  def self.config_file_path
    File.join(RAILS_ROOT, "config", config_file_name)
  end
  
  def self.redirect_url(opts={})
    load_config if @@redirect_url.blank?
    if opts[:partner].blank?
      opts[:partner] = Partner::DEFAULT_ID
    end
    "#{@@redirect_url}?#{opts.collect{|k,v| v.blank? ? nil : "#{k}=#{v}"}.compact.join('&')}"
  end
  
  def self.browsers
    load_config if @@browsers.blank?
    @@browsers
  end
  
  def self.is_mobile_request?(req)
    ua = req.user_agent
    return false if ua.blank?
    self.browsers.each do |browser|
      return true if ua.downcase =~ /#{browser.downcase}/
    end
    return false
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