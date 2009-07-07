Given /^I have completed step 1$/ do
  @registrant = Factory.create(:step_1_registrant)
end

When /^I am (\d+) years old$/ do |age|
  fill_in("date of birth", :with => age.to_i.years.ago.to_date)
end

