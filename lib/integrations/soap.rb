module Integrations
  class Soap
    
    def self.make_request(url, xml_content)
      return RestClient.post(url, xml_content, :content_type=>"application/soap+xml;charset=UTF-8")
    end
    
  end
end