When /^I click the register button/ do
  click_link "rtv-widget-link"
end

Then /^I should see the overlay$/ do
  selenium.select_frame "rtvModalPopupFrame"
end

After('@iframe') do
  selenium.select_frame "relative=top"
end