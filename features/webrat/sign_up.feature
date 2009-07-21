Feature: Register
  In order to get access to partner portal
  A partner
  Should be able to register

    Scenario: Partner registers with invalid data
      When I go to the register page
      And I fill in "Email" with "invalidemail"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with ""
      And I press "Register"
      Then I should see error messages

    Scenario: Partner registers with valid data
      When I go to the register page
      And I fill in "Username" with "Bullwinkle"
      And I fill in "Email" with "email@person.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password"
      And I press "Register"
      Then I should be on the partner dashboard page
