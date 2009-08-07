When /^I click the register button/ do
  click_link "rtv-widget-link"
end

When /^I hover over the "([^\"]*)" tooltip$/ do |tooltip_id|
  selenium.mouse_over "tooltip-#{tooltip_id}"
end

When /^I stop hovering over the "([^\"]*)" tooltip$/ do |tooltip_id|
  selenium.mouse_out "tooltip-#{tooltip_id}"
end

Then /^I should see the overlay$/ do
  selenium.select_frame "rtvModalPopupFrame"
end

After('@iframe') do
  selenium.select_frame "relative=top"
end