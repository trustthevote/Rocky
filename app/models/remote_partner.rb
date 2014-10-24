class RemotePartner < ActiveResource::Base
  self.site = RockyConf.api_host_name
  self.prefix = "/api/v3/"
  self.element_name = "partner"
  
end