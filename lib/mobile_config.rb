class MobileConfig
  
  cattr_accessor :redirect_url, :browsers
  
  def self.redirect_url(opts={})
    if opts[:partner].blank?
      opts[:partner] = Partner::DEFAULT_ID
    end
    "#{RockyConf.mobile_redirect_url}?#{opts.collect{|k,v| v.blank? ? nil : "#{k}=#{v}"}.compact.sort.join('&')}"
  end
  
  def self.browsers
    RockyConf.mobile_browsers
  end
  
  def self.is_mobile_request?(req)
    ua = req.user_agent
    return false if ua.blank?
    self.browsers.each do |browser|
      return true if ua.downcase =~ /#{browser.downcase}/
    end
    return false
  end
    
end