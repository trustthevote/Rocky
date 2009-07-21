# General

Then /^I should see error messages$/ do
  assert_match /error(s)? prohibited/m, response.body
end

# Database

Given /^no partner exists with a login of "(.*)"$/ do |login|
  assert_nil Partner.find_by_login(login)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |login, password|
  partner = Factory :partner,
    :login                 => login,
    :password              => password,
    :password_confirmation => password
end 

# Session

Then /^I should be signed in$/ do
  assert_not_nil controller.send(:current_partner_session)
end

Then /^I should be signed out$/ do
  assert_nil controller.send(:current_partner_session)
end

When /^session is cleared$/ do
  request.reset_session
  controller.instance_variable_set(:@current_partner, nil)
  controller.instance_variable_set(:@current_partner_session, nil)
end

Then /^I should be forbidden$/ do
  assert_response :forbidden
end

# Actions

When /^I sign in as "(.*)\/(.*)"$/ do |login, password|
  When %{I go to the partner sign in page}
  And %{I fill in "Login" with "#{login}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Log In"}
end

When /^I sign out$/ do
  visit '/session', :delete
end

# When /^I request password reset link to be sent to "(.*)"$/ do |login|
#   When %{I go to the password reset request page}
#   And %{I fill in "Email address" with "#{login}"}
#   And %{I press "Reset password"}
# end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  And %{I fill in "Choose password" with "#{password}"}
  And %{I fill in "Confirm password" with "#{confirmation}"}
  And %{I press "Save this password"}
end

When /^I return next time$/ do
  When %{session is cleared}
  And %{I go to the homepage}
end
