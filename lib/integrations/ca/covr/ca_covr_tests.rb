# require './lib/integrations/ca/covr/ca_covr_tests'

class CaCovrTests
  
  TESTS = %w(success-max success-min fail-max-lastname fail-min-agencycode fail-min-disclosures fail-min-residentid)
  
  attr_reader :test_name
  attr_reader :response
  attr_writer :url
  attr_writer :key
  
  def initialize(test_name)
    raise "Test #{test_name} not supported" unless TESTS.include?(test_name.to_s)
    @test_name = test_name
  end
  
  TESTS.each do |t|
    define_method("self.test_#{t.underscore}") do
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
  
  def compare_resposne
    @expected_response = xml_response_contents
    @diff = Diffy::Diff.new(@response, @expected_response)
  end
  
  def return_test_results
    puts @diff
    puts "#{test_name} test done."
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