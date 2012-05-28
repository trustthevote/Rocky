Feature: Step 3
  In order to provide id and changes
  As a registrant
  I want to enter id, phone and changes

  Background:

    Scenario: enter basic data
     Given I have completed step 2
      When I go to the step 3 page
       And I fill in "ID Number" with "1234"
       And I fill in "Phone" with "415-555-4254"
       And I select "Mobile" from "registrant_phone_type"
       And I check "Send me txt messages"
       And I press "registrant_submit"
      Then I should see "Stay Informed and Take Action"

    Scenario: first time registrant
     Given I have completed step 2
       And I am a first time registrant
      When I go to the step 3 page
      Then I should not see "I have changed my name"
       And I should not see "I have changed my address"

    Scenario: changing name
     Given I have completed step 2
      When I go to the step 3 page
       And I fill in "ID Number" with "1234"
       And I check "I have changed my name"
       And I select "Mr." from "title"
       And I fill in "first" with "John"
       And I fill in "last" with "Public"
       And I press "registrant_submit"
      Then I should see "Stay Informed and Take Action"

    Scenario: changing address
     Given I have completed step 2
      When I go to the step 3 page
       And I fill in "ID Number" with "1234"
       And I check "I have changed my address"
       And I fill in "address" with "123 Market St."
       And I fill in "city" with "Pittsburgh"
       And I select "Pennsylvania" from "state"
       And I fill in "zip code" with "15215"
       And I press "registrant_submit"
      Then I should see "Stay Informed and Take Action"

    Scenario: default prev state to home state
      Given I have completed step 2
      When I go to the step 3 page
      Then I should see "Pennsylvania" in select box "registrant_prev_state_abbrev"

    # Step 3 is SMS, Step 4 is email and volunteer
    Scenario: User sees RTV SMS opt-in options for partner 1
      Given I have completed step 2
      When I go to the step 3 page
      And I should see a checkbox for "Send me txt messages from Rock the Vote"
      When I check "Send me txt messages from Rock the Vote"
      And I press "registrant_submit"
      Then I should be signed up for "opt_in_sms"
      And I should not be signed up for "partner_opt_in_sms"

    @wip
    Scenario: User sees RTV and partner SMS opt-in options for partner configured to have rtv and partner opt-ins, and checks partner-sms
      Given the following partner exists:
        | organization   | rtv_sms_opt_in | partner_sms_opt_in |
        | Opt-in Partner | true           | true               |        
      And I have completed step 2 from that partner
      When I go to the step 3 page
      Then I should see a checkbox for "Send me txt messages from Rock the Vote"
      And I should see a checkbox for "Send me txt messages from Opt-in Partner"
      When I check "Receive SMS from Opt-in Partner"
      And I press "registrant_submit"
      Then I should be signed up for "partner_opt_in_sms"
      And I should not be signed up for "rtv_opt_in_sms"
    

    @wip-l
    Scenario: User sees only RTV opt-in options for partner configured to have rtv opt-ins and checks rtv-sms
      Given the following partner exists:
        | organization   | rtv_sms_opt_in | partner_sms_opt_in  |
        | Opt-in Partner | true           | false               |        
      And I have completed step 2 from that partner
      When I go to the step 3 page
      Then I should see a checkbox for "Send me txt messages from Rock the Vote"
      And I should not see a checkbox for "Send me txt messages from Opt-in Partner"
      When I check "Receive SMS from Rock the Vote"
      And I press "registrant_submit"
      Then I should not be signed up for "partner_opt_in_sms"
      And I should be signed up for "rtv_opt_in_sms"


    @wip-l
    Scenario: User sees only partner opt-in options for partner configured to have partner opt-ins and checks and partner-volunteer
      Given the following partner exists:
        | organization   | rtv_sms_opt_in | partner_sms_opt_in  |
        | Opt-in Partner | false          | true                |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should not see a checkbox for "Send me txt messages from Rock the Vote"
      And I should see a checkbox for "Send me txt messages from Opt-in Partner"
      When I check "I'd like to volunteer for Opt-in Partner"
      And I press "registrant_submit"
      Then I should be signed up for "partner_opt_in_sms"
      And I should not be signed up for "rtv_opt_in_sms"

    @wip-l
    Scenario: User sees no opt-in options for partner configured without opt-ins
      Given the following partner exists:
        | organization   | rtv_sms_opt_in | partner_sms_opt_in  |
        | Opt-in Partner | false          | false               |        
      And I have completed step 3 from that partner
      When I go to the step 4 page
      Then I should not see a checkbox for "Receive SMS from Rock the Vote"
      And I should not see a checkbox for "Receive SMS from Opt-in Partner"
      And I press "registrant_submit"
      Then I should not be signed up for "partner_opt_in_sms"
      And I should not be signed up for "rtv_opt_in_sms"
  
  
    