Given(/^I override the states I18n file for english and spanish$/) do 
  Translation.stub(:base_directory) {
    Rails.root.join("spec/fixtures/files/translator_ui/locales")
  }
  I18n.load_path = Dir[Rails.root.join('spec/fixtures/files/translator_ui', 'locales', '*.{rb,yml}').to_s]
  I18n.load_path += Dir[Rails.root.join('spec/fixtures/files/translator_ui', 'locales', 'states', '*.{rb,yml}').to_s]
  I18n.backend.reload!
end

Given(/^I override the tmp translation file path and clear them$/) do 
  tmp_dir = Rails.root.join("spec/fixtures/files/translator_ui/tmp")
  `rm -rf #{tmp_dir} && mkdir -p #{tmp_dir}`
  Translation.stub(:tmp_file_dir).and_return(tmp_dir)
end    
  

Given(/^I override the set of available locales$/) do 
  I18n.stub(:available_locales) {
    [:en, :es]
  }
end


Then(/^I should see all languages and types$/) do
  I18n.available_locales.each do |l|
    page.should have_content("(#{l})")
  end
end

Then(/^I should see all the keys from the english states\/en\.yml$/) do
  page.should have_content("val1")
  page.should have_content("val2")
end

Then(/^I should see the full key name for each english states item$/) do
  page.should have_content("states.testing.val1")
  page.should have_content("states.testing.val2")
end


Then(/^I should see the english value for each english states item$/) do
  page.should have_content "Number One - %{variable}"
  page.should have_content "Number Two"
end

Then(/^I should see instructions for interpolation variables$/) do
  page.should have_content("Instructions for Translator")
  page.should have_content("Please keep '%{variable}' intact")
end

Then(/^I should see instructions provided in the english file$/) do
  page.should have_content("Special Instructions for Val 1")
  page.should_not have_content('val1_translation_instructions')
  
end

Then(/^a tmp translation file should be created$/) do
  File.exists?(Rails.root.join("spec/fixtures/files/translator_ui/tmp/states-es.yml")).should be_truthy
end

Then(/^there should not be an email sent$/) do
  ActionMailer::Base.deliveries.count.should == 0
end

Then(/^there should be an email sent with an attachment$/) do
  ActionMailer::Base.deliveries.count.should == 1
  ActionMailer::Base.deliveries.last.attachments.size.should == 1
end

Then(/^I should get a PDF$/) do
  puts page.response_headers.to_s
  page.response_headers['Content-Type'].should == "application/pdf"
end