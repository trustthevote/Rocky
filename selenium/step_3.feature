Feature: Step 3
  In order to change name or address
  As a registrant
  I want to update name, address

  Background:
    Given I have completed step 2
    When I go to the step 3 page

    Scenario: do not have name change
      Then I should not see "Previous Name"
       And I should not see "First"

    Scenario: have name change
      When I check "I have changed my name"
      Then I should see "Previous Name"
       And I should see "First"

    Scenario: do not have address change
      Then I should not see "Previous Address"
       And I should not see "State"

    Scenario: have address change
      When I check "I have changed my Address"
      Then I should see "Previous Address"
       And I should see "State"
