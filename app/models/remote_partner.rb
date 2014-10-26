class RemotePartner < ActiveResource::Base
  self.site = RockyConf.api_host_name
  self.prefix = "/api/v3/"
  self.element_name = "partner"
  
  
  def self.find_by_id(id)
    if id != nil
      self.find(id)
    else
      nil
    end
  rescue
    nil
  end
  
  def to_param
    self.id
  end
  
  (Partner.column_names + [:custom_logo, :header_logo_url]).each do |column|
    define_method "#{column}" do
      self.attributes[column] || nil
    end
    define_method "#{column}=" do |val|
      self.attributes[column]= val
    end
  end
  
  def custom_logo?
    custom_logo == true
  end
  
  # [:custom_logo?, :partner_assets_host].each do |method|
  #   delegate method, :to=> :partner
  # end
  #
  # def partner
  #   @partner ||= Partner.new(attributes)
  # end
  
end