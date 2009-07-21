Feature: Log out
  To protect my account from unauthorized access
  A logged in partner
  Should be able to log out

    Scenario: Partner logs out
      Given I registered with "bullwinkle/password"
      When I log in as "bullwinkle/password"
      Then I should be logged in
      And I follow "Log out"
      Then I should see "Logged out"
      And I should be logged out
