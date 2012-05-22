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
       And I fill in "registrant_survey_answer_1" with "o hai"
       And I fill in "registrant_survey_answer_2" with "kthxbye"
       And I press "registrant_submit"
      Then I should see "Confirm"

    Scenario: enter data
     Given I have completed step 3
      When I go to the step 4 page
      Then I should not see "Receive txt messages"


    # Step 3 is SMS, Step 4 is email and volunteer
    @wip
    Scenario: User sees RTV opt-in options for partner 1
      Given I have completed step 3
      When I go to the step 4 page
      Then I should see a checkbox for "Receive emails"
      And I should see a checkbox for "I'd like to volunteer"
      When I check "Receive emails"
      And I press "registrant_submit"
      Then I should be signed up for "opt_in_email" #rtv_opt_in
      And I should not be signed up for "volunteer" #ask_for_volunteer ? rtv_opt_in
    
    @wip-l
    Scenario: User sees RTV and partner opt-in options for partner configured to have rtv and partner opt-ins, and checks rtv-volunteer and partner-email
      Given the following partner exists:
        | name           | rtv_opt_in | partner_opt_in |
        | Opt-in Partner | true       | true           |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "Receive emails from Opt-in Partner"
      And I should see a checkbox for "I'd like to volunteer for Rock the Vote"
      And I should see a checkbox for "I'd like to volunteer for Opt-in Partner"
      When I check "Receive emails from Opt-in Partner"
      And I check "I'd like to volunteer for Rock the Vote"
      And I press "registrant_submit"
      Then I should be signed up for "partner_opt_in_email"
      And I should be signed up for "rtv_volunteer"
      And I should not be signed up for "rtv_opt_in_email"
      And I should not be signed up for "partner_volunteer"
      
    
    @wip-l
    Scenario: User sees only RTV opt-in options for partner configured to have rtv opt-ins and checks rtv-email
      Given the following partner exists:
        | name           | rtv_opt_in | partner_opt_in  |
        | Opt-in Partner | true       | false           |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "Receive emails from Opt-in Partner"
      And I should not see a checkbox for "I'd like to volunteer for Rock the Vote"
      And I should not see a checkbox for "I'd like to volunteer for Opt-in Partner"
      When I check "Receive emails from Rock the Vote"
      And I press "registrant_submit"
      Then I should not be signed up for "partner_opt_in_email"
      And I should not be signed up for "rtv_volunteer"
      And I should be signed up for "rtv_opt_in_email"
      And I should not be signed up for "partner_volunteer"
    
    
    @wip-l
    Scenario: User sees only partner opt-in options for partner configured to have partner opt-ins and checks and partner-volunteer
      Given the following partner exists:
        | name           | rtv_opt_in | partner_opt_in  |
        | Opt-in Partner | false      | true            |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should not see a checkbox for "Receive emails from Rock the Vote"
      And I should not see a checkbox for "Receive emails from Opt-in Partner"
      And I should see a checkbox for "I'd like to volunteer for Rock the Vote"
      And I should see a checkbox for "I'd like to volunteer for Opt-in Partner"
      When I check "I'd like to volunteer for Opt-in Partner"
      And I press "registrant_submit"
      Then I should not be signed up for "partner_opt_in_email"
      And I should not be signed up for "rtv_volunteer"
      And I should not be signed up for "rtv_opt_in_email"
      And I should be signed up for "partner_volunteer"
    
    @wip-l
    Scenario: User sees no opt-in options for partner configured without opt-ins
      Given the following partner exists:
        | name           | rtv_opt_in | partner_opt_in  |
        | Opt-in Partner | false      | false           |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "Receive emails from Opt-in Partner"
      And I should not see a checkbox for "I'd like to volunteer for Rock the Vote"
      And I should not see a checkbox for "I'd like to volunteer for Opt-in Partner"
      And I press "registrant_submit"
      Then I should not be signed up for "partner_opt_in_email"
      And I should not be signed up for "rtv_volunteer"
      And I should not be signed up for "rtv_opt_in_email"
      And I should not be signed up for "partner_volunteer"
    
    