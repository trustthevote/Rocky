Feature: Step 3
  In order to provide id and changes
  As a registrant
  I want to enter id, phone and changes

  Background:
    Given I have completed step 2
     And I am a first time registrant
    When I go to the step 3 page

    Scenario: first time registrant
     Given I fill in "ID Number" with "1234"
       And I fill in "Phone" with "415-555-4254"
       And I press "Submit"
      Then I should see "Gotcha"

    Scenario: changing name
     Given I fill in "ID Number" with "1234"
       And I check "I have changed my name"
       And I select "Mr." from "title"
       And I fill in "first" with "John"
       And I fill in "last" with "Public"
       And I press "Submit"
      Then I should see "Gotcha"

    Scenario: changing address
     Given I fill in "ID Number" with "1234"
       And I check "I have changed my address"
       And I fill in "address" with "123 Market St."
       And I fill in "city" with "Pittsburgh"
       And I select "Pennsylvania" from "state"
       And I fill in "zip code" with "15215"
       And I press "Submit"
      Then I should see "Gotcha"
