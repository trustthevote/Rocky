Feature: Sign out
  To protect my account from unauthorized access
  A signed in partner
  Should be able to sign out

    Scenario: Partner signs out
      Given I am signed up and confirmed as "email@person.com/password"
      When I sign in as "email@person.com/password"
      Then I should be signed in
      And I sign out
      Then I should see "Signed out"
      And I should be signed out

