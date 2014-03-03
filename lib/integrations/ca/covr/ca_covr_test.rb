# require './lib/integrations/ca/covr/ca_covr_tests'

class CaCovrTest
  
  TESTS = %w(success-max success-min fail-max-lastname fail-min-agencycode fail-min-disclosures fail-min-residentid)
  
  attr_reader :test_name
  attr_reader :response
  attr_writer :url
  attr_writer :key
  
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
  end
  
  def make_request
    @response = Integrations::Soap.make_request(url, xml_request_contents)
  end
  
  def compare_response
    @expected_response = xml_response_contents
    deuniquify_responses
    @diff = Diffy::Diff.new(@response, @expected_response)
  end
  
  def deuniquify_responses
    if is_success_test?
      @response = @response.gsub(/\<Token\>.+\<\/Token\>/,"TOKEN")
      @expected_response = @expected_response.gsub(/\<Token\>.+\<\/Token\>/,"TOKEN")
    end
  end
  
  def return_test_results
    puts "\n\n"
    puts @diff
    if @diff.to_s.empty?
      puts "#{test_name} test SUCCESS."
    else
      puts "#{test_name} test FAIL."
    end
    puts "\n\n"
  end
  
  def url
    @url ||= "https://covrapitest.sos.ca.gov/PostingEntityInterfaceService.svc"
  end
  
  def key
    @key ||= "d2DE1Nht8I"
  end
  
  def xml_request_contents
    self.class.xml_request_contents(self.test_name)
  end
  
  def xml_response_contents
    self.class.xml_response_contents(self.test_name)
  end
  
  def is_success_test?
    test_name =~ /^success-/
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
  
end