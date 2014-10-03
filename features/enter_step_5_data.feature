Feature: Step 5
  In order to review what I entered
  As a registrant
  I want to read and attest

    Scenario: see summary
     Given I have completed step 4
      When I go to the step 5 page
      Then I should see "Review"
      
    @passing
    Scenario: Don't see email address when not collected
    Given I have completed step 4 without an email address
     When I go to the step 5 page
     Then I should not see "Email Address"

    Scenario: forced to make a selection
     Given I have completed step 4
      When I go to the step 5 page
       And I uncheck "registrant_attest_true"
       And I press "registrant_submit"
      Then I should see "Review"

    @passing
    Scenario Outline: Go back as a <state> resident
      Given I have completed step 4 as a resident of "<state>" state
      And I have a state license
      When I go to the step 5 page
      And I follow "< Previous Step"
      Then I should see "Additional Registration Information"

      Examples:
        | state      |
        | Washington |
        | Arizona    |
        | California |
        | Colorado   |
      
      
    @passing
    Scenario: Go back when skipping step 4
      Given the following partner exists:
        | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers | rtv_sms_opt_in | partner_sms_opt_in | survey_question_1_en | survey_question_2_en |
        | false     | false         | false         | false             | false   | false       | | |
      And I have completed step 4 from that partner
      When I go to the step 5 page
      And I follow "< Previous Step"
      Then I should see "Additional Registration Information"
      

    @cleanup_pdf
    Scenario: enter data
     Given I have completed step 4
      When I go to the step 5 page
       And I check "registrant_attest_true"
       And I press "registrant_submit"
      Then I should see "Print Your Form"


    @cleanup_pdf @passing
    Scenario: Custom zip-code-based addreses
     Given I have completed step 4
       And my zip code is "00501"
      When I go to the step 5 page
       And I check "registrant_attest_true"
       And I press "registrant_submit"
      Then I should see "Print Your Form"
       And my confirmation email should include "542 Forbes Avenue"
       And my confirmation email should include "Suite 609"
       And my confirmation email should include "Pittsburgh, LA 15219-2913"
