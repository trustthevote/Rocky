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


    #because of layout change we'll just allow this for now
    @passing
    Scenario: User CAN sign up for opt_in_sms if phone isn't provided
      Given the following partner exists:
        | organization   | rtv_sms_opt_in | partner_sms_opt_in  |
        | Opt-in Partner | true           | false               |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should see a checkbox for "Send me txt messages from Rock the Vote"
      And I should not see a checkbox for "Send me txt messages from Opt-in Partner"
      When I check "Send me txt messages from Rock the Vote"
      And I press "registrant_submit"
      Then I should not see "Stay Informed and Take Action"
      And I should not see "Required if receiving TXT"

    @passing
    Scenario: User sees RTV SMS opt-in options for partner 1
      Given I have completed step 3
      And my phone number is not blank
      When I go to the step 4 page
      Then I should see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "Send me txt messages from Rock the Vote"
      When I check "Receive emails from Rock the Vote"
      And I check "Send me txt messages from Rock the Vote"
      And I press "registrant_submit"
      Then I should be signed up for "opt_in_sms"
      And I should not be signed up for "partner_opt_in_sms"
      And I should be signed up for "opt_in_email" 
      And I should not be signed up for "volunteer" 

    
    @passing
    Scenario: User does not see email opt-ins if not collecting email
      Given I have completed step 3 without an email address
      And the setting for allowing ask-for-volunteer is true        
      When I go to the step 4 page
      Then I should not see a checkbox for "Receive emails from Rock the Vote"
      And I should see a checkbox for "I would like to volunteer with Rock the Vote"
      And I press "registrant_submit"
      Then I should not be signed up for "opt_in_email" 

    @passing
    Scenario: User does not see ask for volunteer if setting is false
      Given I have completed step 3
      And the setting for allowing ask-for-volunteer is false        
      When I go to the step 4 page
      Then I should not see a checkbox for "I would like to volunteer with Rock the Vote"
    
    
    @passing
    Scenario: User does not see RTV ask for volunteer if setting is false even if partner is true
      Given the following partner exists:
        | organization   | ask_for_volunteers | partner_ask_for_volunteers | 
        | Opt-in Partner | true               | true                       |
      And the setting for allowing ask-for-volunteer is false        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      And I should not see a checkbox for "I would like to volunteer with Rock the Vote"
      And I should see a checkbox for "I would like to volunteer with Opt-in Partner"
      
    
    @passing
    Scenario: User redirected to step 5 when there are no opt ins or survey questions
      Given the following partner exists:
        | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers | rtv_sms_opt_in | partner_sms_opt_in | survey_question_1_en | survey_question_2_en |
        | false     | false         | false         | false             | false   | false       | | |
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should see "Confirm"
      
    @passing
    Scenario: Go back when skipping step 3
      Given the following partner exists:
        | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers | rtv_sms_opt_in | partner_sms_opt_in | survey_question_1_en | survey_question_2_en |
        | false     | false         | false         | false             | false   | false       | | |
      And I have completed step 4 from that partner as a resident of "Nevada" state
      When I go to the step 4 page
      And I follow "< Previous Step"
      Then I should see "Personal Information"
      
    
  
    @passing
    Scenario: User sees RTV and partner SMS opt-in options for partner configured to have rtv and partner opt-ins, and checks partner-sms
      Given the following partner exists:
        | organization   | rtv_sms_opt_in | partner_sms_opt_in |
        | Opt-in Partner | true           | true               |        
      And I have completed step 3 from that partner
      And my phone number is not blank
      When I go to the step 4 page
      Then I should see a checkbox for "Send me txt messages from Rock the Vote"
      And I should see a checkbox for "Send me txt messages from Opt-in Partner"
      When I check "Send me txt messages from Opt-in Partner"
      When I uncheck "Send me txt messages from Rock the Vote"
      And I press "registrant_submit"
      Then I should be signed up for "partner_opt_in_sms"
      And I should not be signed up for "opt_in_sms"

    
    
    @passing
    Scenario Outline: User sees RTV and partner opt-in options as configured for the partner
      Given the following partner exists:
        | organization   | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers | rtv_sms_opt_in | partner_sms_opt_in |
        | Opt-in Partner | <rtv_email>      | <rtv_volunteer>    | <partner_email>      | <partner_volunteer>        | <rtv_sms>      | <partner_sms>      |
      And the setting for allowing ask-for-volunteer is true        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I <see_rtv_email_checkbox> see a checkbox for "Receive emails from Rock the Vote"
      And I <see_partner_email_checkbox> see a checkbox for "Receive emails from Opt-in Partner"
      And I <see_rtv_sms_checkbox> see a checkbox for "Send me txt messages from Rock the Vote"
      And I <see_partner_sms_checkbox> see a checkbox for "Send me txt messages from Opt-in Partner"
      And I <see_rtv_volunteer_checkbox> see a checkbox for "I would like to volunteer with Rock the Vote"
      And I <see_parnter_volunteer_checkbox> see a checkbox for "I would like to volunteer with Opt-in Partner"
      And I <see_rtv_instructions> see "We will send you timely election reminders, your polling place location, and information about music and issues."
      
      Examples:
        | rtv_email | rtv_volunteer | partner_email | partner_volunteer | rtv_sms | partner_sms | see_rtv_email_checkbox | see_rtv_volunteer_checkbox | see_partner_email_checkbox | see_parnter_volunteer_checkbox | see_rtv_instructions | see_rtv_sms_checkbox | see_partner_sms_checkbox |
        | true      | true          | true          | true              | true    | true        | should                 | should                     | should                     | should                         | should               | should               | should                   |
        | true      | true          | true          | false             | true    | false       | should                 | should                     | should                     | should not                     | should               | should               | should not               |
        | true      | true          | false         | true              | false   | true        | should                 | should                     | should not                 | should                         | should               | should not           | should                   |
        | true      | true          | false         | false             | true    | false       | should                 | should                     | should not                 | should not                     | should               | should               | should not               |
        | true      | false         | true          | true              | false   | true        | should                 | should not                 | should                     | should                         | should               | should not           | should                   |
        | false     | true          | true          | true              | true    | false       | should not             | should                     | should                     | should                         | should not           | should               | should not               |
        | false     | true          | true          | false             | false   | true        | should not             | should                     | should                     | should not                     | should not           | should not           | should                   |
        | false     | false         | true          | true              | true    | false       | should not             | should not                 | should                     | should                         | should not           | should               | should not               |
        | true      | false         | false         | true              | false   | true        | should                 | should not                 | should not                 | should                         | should               | should not           | should                   |
        | false     | false         | false         | true              | false   | false       | should not             | should not                 | should not                 | should                         | should not           | should not           | should not               |
        | true      | false         | false         | false             | true    | true        | should                 | should not                 | should not                 | should not                     | should               | should               | should                   |
        | false     | false         | false         | false             | false   | false       | should not             | should not                 | should not                 | should not                     | should not           | should not           | should not               |
      
    @passing
    Scenario: User signs up for everything
      Given the following partner exists:
        | organization   | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers | rtv_sms_opt_in | partner_sms_opt_in |
        | Opt-in Partner | true             | true               | true                 | true                       | true           | true               |       
      And I have completed step 3 from that partner
      And my phone number is not blank
      When I go to the step 4 page
      And I check "Receive emails from Opt-in Partner"
      And I check "I would like to volunteer with Opt-in Partner"
      And I check "Receive emails from Rock the Vote"
      And I check "I would like to volunteer with Rock the Vote"
      And I check "Send me txt messages from Rock the Vote"
      And I check "Send me txt messages from Opt-in Partner"
      And I press "registrant_submit"
      Then I should be signed up for "opt_in_email"
      And I should be signed up for "partner_opt_in_email"
      And I should be signed up for "volunteer"
      And I should be signed up for "partner_volunteer"
      And I should be signed up for "opt_in_sms"
      And I should be signed up for "partner_opt_in_sms"

    @passing
    Scenario: User signs up for nothing
      Given the following partner exists:
        | organization   | rtv_email_opt_in | ask_for_volunteers | partner_email_opt_in | partner_ask_for_volunteers |  rtv_sms_opt_in | partner_sms_opt_in |
        | Opt-in Partner | true             | true               | true                 | true                       |  true           | true               |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      And I uncheck "Receive emails from Opt-in Partner"
      And I uncheck "I would like to volunteer with Opt-in Partner"
      And I uncheck "Receive emails from Rock the Vote"
      And I uncheck "I would like to volunteer with Rock the Vote"
      And I uncheck "Send me txt messages from Rock the Vote"
      And I uncheck "Send me txt messages from Opt-in Partner"
      And I press "registrant_submit"
      Then I should not be signed up for "opt_in_email"
      And I should not be signed up for "partner_opt_in_email"
      And I should not be signed up for "volunteer"
      And I should not be signed up for "partner_volunteer"
      And I should not be signed up for "opt_in_sms"
      And I should not be signed up for "partner_opt_in_sms"
      
    
    
    @passing
    Scenario Outline: <state> resident selects to finish registration with Rock the Vote
      Given I have completed step 3 as a resident of "<state>" state
      And I have a state license
      When I go to the step 4 page
      Then I should see a field for "ID"
      And I should see a field for "Race"
      And I <requires_party> see a field for "Party"
      When I press "registrant_skip_state_online_registration"
      Then I should see "Confirm"

      Examples:
        | state      | state_abbr | requires_party |
        | Washington | WA         | should not     |
        | Arizona    | AZ         | should         |  
        | Colorado   | CO         | should         |
        | Nevada     | NV         | should         |
        | California | CA         | should         |

    @passing
    Scenario: CA resident eligible and approved for OVR doesn't agree to disclosures
      Given I have completed step 3 as a resident of "California" state
      And I have a state license
      And COVR responses return successes
      When I go to the step 4 page
      And I uncheck "registrant_ca_disclosures"
      And I press "registrant_state_online_registration"
      Then I should see "Hang on. You are eligible to register online in your state."

    @passing
    Scenario: CA resident eligible and approved for OVR agrees to disclosures
      Given I have completed step 3 as a resident of "California" state
      And I have a state license
      And COVR responses return successes
      When I go to the step 4 page
      And I check "registrant_ca_disclosures"
      And I press "registrant_state_online_registration"
      Then I should see an iFrame for the California State online system


