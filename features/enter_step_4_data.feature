Feature: Step 4
  In order to opt in and answer survey questions
  As a registrant
  I want to opt in and speak out

    @passing
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

    @passing
    Scenario: Answer questions
      Given the following partner exists:
        | organization        | survey_question_1_en | survey_question_2_en |
        | Partner w/questions | Who?                 | What?                |      
      And I have completed step 3 from that partner
      And my phone number is not blank
      When I go to the step 4 page
      And I check "Receive emails"
      And I fill in "registrant_survey_answer_1" with "me"
      And I fill in "registrant_survey_answer_2" with "register"
      And I press "registrant_submit"
      Then I should see "Confirm"
      And my value for "survey_question_1" should be "Who?"
      And my value for "survey_question_2" should be "What?"
      When the partner changes "survey_question_1_en" to "Something Else"
      And the partner changes "survey_question_2_en" to "Something Else"
      Then my value for "survey_question_1" should be "Who?"
      And my value for "survey_question_2" should be "What?"
        
    @passing
    Scenario: Answer questions
      Given the following partner exists:
        | organization        | survey_question_1_es   | survey_question_2_es |
        | Partner w/questions | Quien?                 | Que?                 |      
      And I have completed step 3 from that partner
      And my locale is "es"
      And my phone number is not blank
      When I go to the step 4 page
      And I fill in "registrant_survey_answer_1" with "me"
      And I fill in "registrant_survey_answer_2" with "register"
      And I press "registrant_submit"
      Then I should see "Confirm"
      And my value for "survey_question_1" should be "Quien?"
      And my value for "survey_question_2" should be "Que?"
      When the partner changes "survey_question_1_es" to "Something Else"
      And the partner changes "survey_question_2_es" to "Something Else"
      Then my value for "survey_question_1" should be "Quien?"
      And my value for "survey_question_2" should be "Que?"



    # Step 3 is SMS, Step 4 is email and volunteer
    #rtv_opt_in
    #ask_for_volunteer ? rtv_opt_in
    Scenario: User sees RTV opt-in options for partner 1
      Given I have completed step 3
      When I go to the step 4 page
      Then I should see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "I would like to volunteer with Rock the Vote"
      When I check "Receive emails from Rock the Vote"
      And I press "registrant_submit"
      Then I should be signed up for "opt_in_email" 
      And I should not be signed up for "volunteer" 
    
    @passing
    Scenario: User does not see email opt-ins if not collecting email
      Given I have completed step 3 without an email address
      When I go to the step 4 page
      Then I should not see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "I would like to volunteer with Rock the Vote"
      And I press "registrant_submit"
      Then I should not be signed up for "opt_in_email" 
    
    
    Scenario Outline: User sees RTV and partner opt-in options as configured for the partner
      Given the following partner exists:
        | organization   | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers |
        | Opt-in Partner | <rtv_email>      | <rtv_volunteer>    | <partner_email>      | <partner_volunteer>       |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I <see_rtv_email_checkbox> see a checkbox for "Receive emails from Rock the Vote"
      And I <see_partner_email_checkbox> see a checkbox for "Receive emails from Opt-in Partner"
      And I <see_rtv_volunteer_checkbox> see a checkbox for "I would like to volunteer with Rock the Vote"
      And I <see_parnter_volunteer_checkbox> see a checkbox for "I would like to volunteer with Opt-in Partner"
      And I <see_rtv_instructions> see "We will send you timely election reminders, your polling place location, and information about music and issues."
      
      Examples:
        | rtv_email | rtv_volunteer | partner_email | partner_volunteer | see_rtv_email_checkbox | see_rtv_volunteer_checkbox | see_partner_email_checkbox | see_parnter_volunteer_checkbox | see_rtv_instructions |
        | true      | true          | true          | true              | should                 | should                     | should                     | should                         | should               |
        | true      | true          | true          | false             | should                 | should                     | should                     | should not                     | should               |
        | true      | true          | false         | true              | should                 | should                     | should not                 | should                         | should               |
        | true      | true          | false         | false             | should                 | should                     | should not                 | should not                     | should               |
        | true      | false         | true          | true              | should                 | should not                 | should                     | should                         | should               |
        | false     | true          | true          | true              | should not             | should                     | should                     | should                         | should not           |
        | false     | true          | true          | false             | should not             | should                     | should                     | should not                     | should not           |
        | false     | false         | true          | true              | should not             | should not                 | should                     | should                         | should not           |
        | true      | false         | false         | true              | should                 | should not                 | should not                 | should                         | should               |
        | false     | false         | false         | true              | should not             | should not                 | should not                 | should                         | should not           |
        | true      | false         | false         | false             | should                 | should not                 | should not                 | should not                     | should               |
        | false     | false         | false         | false             | should not             | should not                 | should not                 | should not                     | should not           |
      
    Scenario: User signs up for everything
      Given the following partner exists:
        | organization   | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers |
        | Opt-in Partner | true             | true              | true                 | true                      |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      And I check "Receive emails from Opt-in Partner"
      And I check "I would like to volunteer with Opt-in Partner"
      And I check "Receive emails from Rock the Vote"
      And I check "I would like to volunteer with Rock the Vote"
      And I press "registrant_submit"
      Then I should be signed up for "opt_in_email"
      And I should be signed up for "partner_opt_in_email"
      And I should be signed up for "volunteer"
      And I should be signed up for "partner_volunteer"


    Scenario: User signs up for nothing
      Given the following partner exists:
        | organization   | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers |
        | Opt-in Partner | true             | true              | true                 | true                      |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      And I uncheck "Receive emails from Opt-in Partner"
      And I uncheck "I would like to volunteer with Opt-in Partner"
      And I uncheck "Receive emails from Rock the Vote"
      And I uncheck "I would like to volunteer with Rock the Vote"
      And I press "registrant_submit"
      Then I should not be signed up for "opt_in_email"
      And I should not be signed up for "partner_opt_in_email"
      And I should not be signed up for "volunteer"
      And I should not be signed up for "partner_volunteer"
      
    
    