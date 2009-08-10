Feature: Step 5
  In order to review what I entered
  As a registrant
  I want to read and attest

    Scenario: see summary
     Given I have completed step 4
      When I go to the step 5 page
      Then I should see "Review"

    Scenario: forced to make a selection
     Given I have completed step 4
      When I go to the step 5 page
       And I uncheck "registrant_attest_true"
       And I press "registrant_submit"
      Then I should see "Review"

    Scenario: enter data
     Given I have completed step 4
      When I go to the step 5 page
       And I check "registrant_attest_true"
       And I press "registrant_submit"
      Then I should see "Print Your Form"
