When /^I hover over the "([^\"]*)" tooltip$/ do |tooltip_id|
  selenium.mouse_over "tooltip-#{tooltip_id}"
end

When /^I stop hovering over the "([^\"]*)" tooltip$/ do |tooltip_id|
  selenium.mouse_out "tooltip-#{tooltip_id}"
end
