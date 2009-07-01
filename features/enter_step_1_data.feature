Feature: Step 1
  In order to establish eligibility
  As a registrant
  I want to enter step 1 data
  
    Scenario: first visit
      Given I am on the home page
      When I go to a new registration page
       And I select "Mr." from "name title"
       And I fill in "first name" with "John"
       And I fill in "last name" with "Public"
       And I fill in "email address" with "john.public@example.com"
       And I fill in "zip code" with "94113"
       And I am 20 years old
       And I click "Submit"
      Then I should see "You are eligible"
