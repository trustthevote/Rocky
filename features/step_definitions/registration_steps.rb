Given /^I have completed step (\d+)$/ do |step_num|
  @registrant = Factory.create("step_#{step_num}_registrant")
end

When /^I am (\d+) years old$/ do |age|
  fill_in("date of birth", :with => age.to_i.years.ago.to_date.strftime("%m/%d/%Y"))
end

Given /^I have not set a locale$/ do
  I18n.locale = nil
end

Given /^I am a first time registrant$/ do
  @registrant.first_registration = true
  @registrant.save
end

Given /^my phone number is not blank$/ do
  @registrant.phone = "415-555-1234"
  @registrant.phone_type = "Mobile"
  @registrant.save
end

Given /^I have not downloaded the PDF before$/ do
  `rm #{@registrant.pdf_path}`
end

Then /^I should see a new download$/ do
  assert File.exists?(@registrant.pdf_path)
  `rm #{@registrant.pdf_path}`
end

Then /^I should see my email$/ do
  Then %Q{the "Email" field should contain "#{@registrant.email_address}"}
end

Then /^I should see my date of birth$/ do
  Then %Q{the "Date of Birth" field should contain "#{@registrant.date_of_birth.year}"}
end

Then /^I should see "([^\"]*)" in select box "([^\"]*)"$/ do |select_value, select_box|
  assert_equal select_value, current_dom.css("##{select_box} option[selected]").text
end

When /^I enter valid data for step 1$/ do
  When %Q{I fill in "email address" with "john.public@example.com"}
  And %Q{I fill in "zip code" with "94113"}
  And %Q{I am 20 years old}
  And %Q{I check "I am a U.S. citizen"}
end

When /^I live in (.*)$/ do |state_name|
  state = GeoState.find_by_name(state_name)
  zip_prefix = GeoState.zip3map.index(state.abbreviation)
  When %Q{I fill in "zip code" with "#{zip_prefix}01"}
end
