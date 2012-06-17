Feature: Step 2
  In order to provide personal information
  As a registrant
  I want to enter name, address
  
    Scenario: first visit
      Given I have completed step 1
      When I go to the step 2 page
       And I select "Mr." from "title"
       And I fill in "first" with "John"
       And I fill in "last" with "Public"
       And I fill in "address" with "123 Market St."
       And I fill in "city" with "Pittsburgh"
       And I press "registrant_submit"
      Then I should see "Additional Registration Information"

    Scenario: default mailing state to home state
      Given I have completed step 1
      When I go to the step 2 page
      Then I should see "Pennsylvania" in select box "registrant_mailing_state_abbrev"

    @wip
    Scenario: fields for a washington state resident
      Given I have completed step 1 as a resident of "Washington" state
      When I go to the step 2 page
      Then I should see a field for "Phone"
      And I should see a field for "Type"
      And I should see a field for "Yes, I have a WA state issued drivers license"
