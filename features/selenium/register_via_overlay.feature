Feature: Register via Overlay
  As a registrant
  In order to register to vote without leaving a partner's page
  I want to use an overlay
  
    Scenario: not be bothered by overlay initially
      Given I visit the Moose page
      Then I should not see "New registrant"

    Scenario: trigger the overlay
      Given I visit the Moose page
      When I click the register button
      Then I should see "New registrant"
