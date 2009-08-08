Feature: Tooltips
  In order to justify entering data
  As a registrant
  I want to see tooltips
  
    Scenario: See the email tooltip
      When I go to a new registration page
      And I hover over the "email_address" tooltip
      Then I should see "to receive more information"

    Scenario: Hide the email tooltip
      When I go to a new registration page
      And I hover over the "email_address" tooltip
      And I stop hovering over the "email_address" tooltip
      Then I should not see "to receive more information"

    Scenario: See state-specific tooltip
     Given I have completed step 2
      And there is localized state data
      When I go to the step 3 page
      And I hover over the "state_id_number" tooltip
      Then I should see "local tooltip"

