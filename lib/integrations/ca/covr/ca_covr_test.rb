# require './lib/integrations/ca/covr/ca_covr_test'

class CaCovrTest
  
  TESTS = %w(success-max success-min fail-max-lastname fail-min-agencycode fail-min-disclosures fail-min-residentid)
  
  attr_reader :test_name
  attr_reader :response, :response2
  attr_writer :url
  attr_writer :key
  attr_writer :step2_url_base
  
  def initialize(test_name)
    raise "Test #{test_name} not supported" unless TESTS.include?(test_name.to_s)
    @test_name = test_name
  end
  
  def self.test_all!
    TESTS.each do |t|
      self.new(t).test!
    end
  end
  
  def test!
    make_request
    compare_response
    return_test_results
    if is_success_test?
      make_step2_request
      compare_response2
      return_test_results2
    end
  end
  
  
  
  
  def make_request
    @response = Integrations::Soap.make_request(url, xml_request_contents)
  end
  
  def make_step2_request
    @response2 = RestClient.get(step_2_url)
  end
  
  def compare_response
    @expected_response = xml_response_contents
    @diff = Diffy::Diff.new(@response.gsub(CA::XML_TOKEN_REGEXP,"TOKEN"), @expected_response.gsub(CA::XML_TOKEN_REGEXP,"TOKEN"))
  end
  
  def compare_response2
    @expected_response2 = html_response2_contents
    @diff2 = Diffy::Diff.new(@response2.gsub(/\r\n?/, "\n").strip, @expected_response2.gsub(/\r\n?/, "\n").strip)
    
  end
  
  
  
  
  
  def return_test_results
    puts "\n\n"
    puts @diff
    if @diff.to_s.empty?
      puts "#{test_name} step 1 test SUCCESS."
    else
      puts "#{test_name} step 1 test FAIL."
    end
    puts "\n\n"
  end
  
  def return_test_results2
    puts "\n\n"
    puts @diff2
    if @diff2.to_s.empty?
      puts "#{test_name} step 2 test SUCCESS."
    else
      puts "#{test_name} step 2 test FAIL."
    end
    puts "\n\n"
  end

  def url
    @url ||= RockyConf.ovr_states.CA.api_settings.api_url
  end
  
  def key
    @key ||= RockyConf.ovr_states.CA.api_settings.api_key
  end
  
  def step_2_url
"#{step_2_url_base}/?language=en-US&t=p&CovrAgencyKey=RTV&PostingAgencyRecordId=#{success_token}"   
  end
  
  def step_2_url_base
    @step_2_url_base ||= RockyConf.ovr_states.CA.api_settings.web_url_base
  end
  
  
  def success_token
    if self.is_success_test?
      @success_token = CA.extract_token_from_xml_response(self.response)
    else
      @success_token = nil
    end
    @success_token
  end
  
  
  def xml_request_contents
    self.class.xml_request_contents(self.test_name).gsub(/API_KEY/, key)
  end
  
  def xml_response_contents
    self.class.xml_response_contents(self.test_name)
  end

  def html_response2_contents
    self.class.html_response2_contents(self.test_name)
  end

  
  def is_success_test?
    !!(xml_response_contents =~ CA::XML_TOKEN_REGEXP)
  end
  
  def self.xml_request_contents(test_name)
    contents = ''
    File.open(Rails.root.join("lib/integrations/ca/covr/fixtures","#{test_name}-req.xml")) do |f|
      contents = f.read
    end
    return contents
  end
  
  def self.xml_response_contents(test_name)
    contents = ''
    File.open(Rails.root.join("lib/integrations/ca/covr/fixtures","#{test_name}-resp.xml")) do |f|
      contents = f.read
    end
    return contents
  end
  
  def self.html_response2_contents(test_name)
    contents = ''
    File.open(Rails.root.join("lib/integrations/ca/covr/fixtures","#{test_name}-resp2.html")) do |f|
      contents = f.read
    end
    return contents
  end
  
end