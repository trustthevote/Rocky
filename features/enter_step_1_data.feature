Feature: Step 1
  In order to establish eligibility
  As a registrant
  I want to enter step 1 data

    Scenario: start
      When I go to a new registration page
      Then I should see "New registrant"

    Scenario: start in Spanish
      When I go to a new Spanish registration page
      Then I should not see "New registrant"
       And I should see "es, txt, registration"

    Scenario: completing step 1
      When I go to a new registration page
       And I have not set a locale
       And I fill in "email address" with "john.public@example.com"
       And I fill in "zip code" with "94113"
       And I am 20 years old
       And I check "I am a U.S. citizen"
       And I press "registrant_submit"
      Then I should see "Personal Information"

    Scenario: completing step 1 in Spanish
      When I go to a new Spanish registration page
       And I have not set a locale
       And I fill in "email address" with "john.public@example.com"
       And I fill in "home zip code" with "94113"
       And I am 20 years old
       And I check "US citizen"
       And I press "registrant_submit"
      Then I should not see "Personal Information"
       And I should see "es, txt, registration"
