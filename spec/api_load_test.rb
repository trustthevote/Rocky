# usage:
# bundle exec ruby spec/api_load_test.rb  

# Config
NUM_THREADS = 25  # Number of concurrent users
NUM_REQUESTS = 20 # How many PDFs each user generates

HOST = "https://rtvdemo:bullwinkle@rtvstaging-web1.osuosl.org"

PATH = "/api/v3/registrations.json"



# View PDF queue status:
# bundle exec rails c staging  (for example)
# copy this method in then run it to see PriorityQueue lenghts
def view_queue
  started = false
  max = 0
  start_time = nil
  end_time = nil
  loop do
    ct = PriorityPdfGeneration.count
    if ct > max
      start_time = Time.now
      started = true
      max = ct
    elsif ct == 0 && started
      end_time = Time.now
      started = false
      puts "Cleared #{max} in #{end_time-start_time} seconds"
    end    
    puts ct
    # puts "Priority Queue"
    # puts "#{PdfGeneration.count}\t#{PriorityPdfGeneration.count}"
    sleep 5
  end
end


  

# This request does not use an email address
require 'rest-client'
require "active_support/core_ext"
class PdfGenRequest
  
  def self.request_body
    {
      :registration => {
        :date_of_birth => "1979-10-24",
        :collect_email_address=>"no",
        :email_address=>'',
        :first_name => "TEST", 
        :home_address => "Colenso", 
        :home_city => "Carrum", 
        :home_state_id => "MA", 
        :home_zip_code => "02113", 
        :last_name => "TEST", 
        :name_title => "Mr.",
        :partner_id => "720", 
        :party => "Democratic", 
        :race => "Other", 
        :id_number => "NONE", 
        :us_citizen => "1", 
        :opt_in_email => "0", 
        :lang => "es", 
        :opt_in_sms => "0"
      }
    }
  end
  
  def request_body
    b = self.class.request_body.dup
    b[:first_name] = b[:first_name]+'-'+self.id
    b
  end
  
  attr_accessor :id, :response
  
  def url
    [HOST, PATH].join
  end
  
  def initialize(id)
    @id = id
  end
  
  def make_request
    response_body = RestClient.post url, self.class.request_body.to_json, :content_type => :json, :accept => :json
    @response = OpenStruct.new({
      :http_code=> response_body.code,
      :http_body=> response_body
    })
  rescue Exception => e
    puts e.message, e.class.name
    @response = e
  end
  
end

responses = {}
request_count = 0

threads = []

# ActiveSupport - pre initialize the to_json method
{a: 'b'}.to_json

start = Time.now

NUM_THREADS.times do |t|
  # new thread
  thr = Thread.new do
    NUM_REQUESTS.times do |r|
      request_count += 1
      req = PdfGenRequest.new("thread-#{t}-request-#{r}")
      puts req.id
      req.make_request
      responses[req.id] = req.response
    end
  end
  threads << thr
end

threads.each {|thr| thr.join }

time = Time.now - start

errors = []
success_count = 0
responses.each do |id, response|
  if response.http_code != 200
    errors << "#{id}: #{response.http_code}\t#{response.http_body}"
  else
    success_count += 1
  end
end

puts "In #{time} seconds:"
puts "#{request_count} Requests. #{success_count} Success, #{errors.size} Errors"
puts "#{request_count/time.to_f} reqs/sec | #{time.to_f/request_count.to_f} secs/req"
puts errors.join("\n")



