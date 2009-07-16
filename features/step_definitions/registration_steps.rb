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
