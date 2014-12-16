module Integrations
  class Soap
    
    def self.make_request(url, xml_content)
      if Rails.env.development?
        return File.new(Rails.root.join("spec/fixtures/files/covr/max_registrant_response.xml")).read
      else
        RestClient.proxy = ENV["PROXIMO_URL"]
        return RestClient::Request.execute(:method=>:post, :payload=>xml_content, :url=>url, :headers=>{:content_type=>"application/soap+xml;charset=UTF-8"}, :timeout=>17, :open_timeout=>3)
        #return RestClient.post(url, xml_content, :content_type=>"application/soap+xml;charset=UTF-8", :timeout => 15)
      end
    end
    
  end
end