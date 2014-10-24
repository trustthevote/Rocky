class RemotePartner < ActiveResource::Base
  self.site = RockyConf.api_host_name
  self.prefix = "/api/v3/"
  self.element_name = "partner"
  
  def self.find_by_id(id)
    self.find(id)
  rescue
    nil
  end
  
end