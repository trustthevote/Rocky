Feature: Tooltips
  In order to justify entering data
  As a registrant
  I want to see tooltips

    Scenario: See the email tooltip
      When I go to a new registration page
      And I hover over the "email_address" tooltip
      Then I should see "We will email you a copy of your voter registration form."

    Scenario: Hide the email tooltip
      When I go to a new registration page
      And I hover over the "email_address" tooltip
      And I stop hovering over the "email_address" tooltip
      Then I should not see "to receive more information"
