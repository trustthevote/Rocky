module Integrations
  class Soap
    
    def self.make_request(url, xml_content)
      if Rails.env.development?
        return File.new(Rails.root.join("spec/fixtures/files/covr/max_registrant_response.xml")).read
      else
        return RestClient.post(url, xml_content, :content_type=>"application/soap+xml;charset=UTF-8")
      end
    end
    
  end
end