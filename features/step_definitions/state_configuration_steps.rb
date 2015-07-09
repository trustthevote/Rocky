# def self.file_path
#   temp_file = tmp_file_path
#   if File.exists?(temp_file)
#     temp_file.to_s
#   else
#     Rails.root.join('db/bootstrap/import/states.yml').to_s
#   end
# end

Given(/^I override the states yml file$/) do
  allow(StateImporter).to receive(:file_path) {
    Rails.root.join('spec/fixtures/files/state_configuration/states.yml').to_s
  }
end


Then(/^I should see default state settings$/) do
  page.should have_content("defaults")
  
  states_hash = YAML::load( File.open( Rails.root.join("spec/fixtures/files/state_configuration/states.yml") ) )
  states_hash['defaults'].each do |key_name, value|
    if value.is_a?(Array)
      page.should have_field("config[defaults.#{key_name}][]")
    else
      page.should have_field("config[defaults.#{key_name}]")
    end
  end  
end

Then(/^I should see all state settings$/) do
  states_hash = YAML::load( File.open( Rails.root.join("spec/fixtures/files/state_configuration/states.yml") ) )
  states_hash.each do |group, hash|
    hash.each do |key_name, value|
      unless %w(abbreviation name).include?(key_name)
        if value.is_a?(Array)
          page.should have_field("config[#{group}.#{key_name}][]")
        else
          page.should have_field("config[#{group}.#{key_name}]")
        end
      end
    end
  end
end

Given(/^I override the tmp state_config file path and clear them$/) do 
  tmp_dir = Rails.root.join("spec/fixtures/files/state_configuration/tmp")
  `rm -rf #{tmp_dir} && mkdir -p #{tmp_dir}`
  StateImporter.stub(:tmp_file_dir).and_return(tmp_dir)
end    

Then(/^a tmp state_config file should be created$/) do
  File.exists?(Rails.root.join("spec/fixtures/files/translator_ui/tmp/states-es.yml")).should be_truthy
end
