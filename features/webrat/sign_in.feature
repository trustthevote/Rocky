Feature: Log in
  In order to get access to protected sections of the site
  A partner
  Should be able to log in

    Scenario: Partner is not registered
      Given no partner exists with a login of "bullwinkle/password"
      When I go to the login page
      And I log in as "bullwinkle/password"
      Then I should see "Login"
      And I should be logged out

   Scenario: Partner enters wrong password
      Given I registered with "bullwinkle/password"
      When I go to the login page
      And I log in as "bullwinkle/wrongpassword"
      Then I should see "Login"
      And I should be logged out

   Scenario: Partner logs in successfully with login
      Given I registered with "bullwinkle/password"
      When I go to the login page
      And I log in as "bullwinkle/password"
      Then I should be on the partner dashboard
      And I should be logged in

   Scenario: Partner logs in successfully with email
      Given I registered with "bullwinkle/password"
      When I go to the login page
      And I log in as "bullwinkle@example.com/password"
      Then I should be on the partner dashboard
      And I should be logged in
      And I should see "Log out"