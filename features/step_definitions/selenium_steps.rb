When /^I hover over the "([^\"]*)" tooltip$/ do |tooltip_id|
  selenium.mouse_over "tooltip-#{tooltip_id}"
end

When /^I stop hovering over the "([^\"]*)" tooltip$/ do |tooltip_id|
  selenium.mouse_out "tooltip-#{tooltip_id}"
end

When /^I ignore the new blank window$/ do
  # TODO: close blank window
  # selenium.close
  selenium.select_window nil
end

# overlay steps

When /^I click the register button/ do
  sleep 1
  click_link "overlay-link"
  sleep 2
end

Then /^I should see the overlay$/ do
  selenium.select_frame "fbContent"
end

After('@iframe') do
  selenium.select_frame "relative=top"
end
