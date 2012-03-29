# response.should be_json_error 'Something'
Spec::Matchers.define :be_json_error do |expected|
  match do |response|
    response.code.should == "400"
    response.body.should == { :message => expected }.to_json
  end
end

# response.should be_json_validation_error 'field', 'error'
Spec::Matchers.define :be_json_validation_error do |field, error|
  match do |response|
    response.code.should == "400"
    response.body.should == { :field_name => field, :message => error }.to_json
  end
end

# response.should be_json_data { :message => 'test' }
Spec::Matchers.define :be_json_data do |expected|
  match do |response|
    response.code.should == "200"
    response.body.should == expected.to_json
  end
end

