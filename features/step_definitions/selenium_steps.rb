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
