Feature: Sign in
  In order to get access to protected sections of the site
  A partner
  Should be able to sign in

    Scenario: Partner is not signed up
      Given no partner exists with a login of "bullwinkle/password"
      When I go to the partner sign in page
      And I sign in as "bullwinkle/password"
      Then I should see "Login"
      And I should be signed out

   Scenario: Partner enters wrong password
      Given I signed up with "bullwinkle/password"
      When I go to the partner sign in page
      And I sign in as "bullwinkle/wrongpassword"
      Then I should see "Login"
      And I should be signed out

   Scenario: Partner signs in successfully with login
      Given I signed up with "bullwinkle/password"
      When I go to the partner sign in page
      And I sign in as "bullwinkle/password"
      Then I should be on the partner dashboard
      And I should be signed in
