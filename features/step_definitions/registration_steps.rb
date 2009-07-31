Given /^I have completed step (\d+)$/ do |step_num|
  @registrant = Factory.create("step_#{step_num}_registrant")
end

When /^I am (\d+) years old$/ do |age|
  fill_in("date of birth", :with => age.to_i.years.ago.to_date)
end

Given /^I have not set a locale$/ do
  I18n.locale = nil
end

Given /^I am a first time registrant$/ do
  @registrant.first_registration = true
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

