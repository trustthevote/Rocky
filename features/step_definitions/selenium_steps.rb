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

When /^I click the close link and confirm with (OK|Cancel)/ do |choice|
  case choice
  when "OK"     ; selenium.choose_ok_on_next_confirmation
  when "Cancel" ; selenium.choose_cancel_on_next_confirmation
  end
  click_link "fbClose"
  selenium.confirmation.should eql("Close voter registration application?")
  sleep 2
end

After('@iframe') do
  selenium.select_frame "relative=top"
end
