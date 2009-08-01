Feature: Step 4
  In order to opt in and answer survey questions
  As a registrant
  I want to opt in and speak out

    Scenario: see form
     Given I have completed step 3
      When I go to the step 4 page
      Then I should see "Hello?"

    Scenario: enter data
     Given I have completed step 3
       And my phone number is not blank
      When I go to the step 4 page
       And I check "Receive emails"
       And I check "Receive txt messages"
       And I fill in "registrant_survey_answer_1" with "o hai"
       And I fill in "registrant_survey_answer_2" with "kthxbye"
       And I press "registrant_submit"
      Then I should see "Confirm"

    Scenario: enter data
     Given I have completed step 3
      When I go to the step 4 page
      Then I should not see "Receive txt messages"
