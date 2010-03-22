Feature: Register via Overlay
  As a registrant
  In order to register to vote without leaving a partner's page
  I want to use an overlay

    @iframe
    Scenario: don't see overlay initially
      Given I am on the Moose page
      Then I should not see "New registrant"

    @iframe
    Scenario: trigger the overlay
      Given I am on the Moose page
      When I click the register button
      Then I should see "New Registrant" in the overlay

    @iframe
    Scenario: close the overlay with confirmation
      Given I am on the Moose page
      When I click the register button
      Then I should see the overlay
      When I click the close link and confirm with Cancel
      Then I should see the overlay
      And I click the close link and confirm with OK
      Then I should not see "New Registrant"
