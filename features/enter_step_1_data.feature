Feature: Step 1
  In order to establish eligibility
  As a registrant
  I want to enter step 1 data
  
    Scenario: first visit
      When I go to a new registration page
       And I fill in "email address" with "john.public@example.com"
       And I fill in "zip code" with "94113"
       And I am 20 years old
       And I check "I am a U.S. citizen"
       And I press "Submit"
      Then I should see "You are eligible"
       And I should see "Personal Information"