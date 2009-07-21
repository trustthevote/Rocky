Feature: Sign up
  In order to get access to partner portal
  A partner
  Should be able to sign up

    Scenario: Partner signs up with invalid data
      When I go to the partner sign up page
      And I fill in "Email" with "invalidemail"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with ""
      And I press "Sign Up"
      Then I should see error messages

    Scenario: Partner signs up with valid data
      When I go to the partner sign up page
      And I fill in "Email" with "email@person.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password"
      And I press "Sign Up"
      Then I should see "instructions for confirming"
      And a confirmation message should be sent to "email@person.com"
