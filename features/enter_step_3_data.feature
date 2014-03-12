Feature: Step 3
  In order to provide id and changes
  As a registrant
  I want to enter id and

  Background:

    Scenario: enter basic data
     Given I have completed step 2
      When I go to the step 3 page
       And I fill in "ID Number" with "1234"
       And I select "Hispanic" from "Race"
       And I select "Democratic" from "Party"
       And I press "registrant_submit"
      Then I should see "Stay Informed and Take Action"



    


    @passing
    Scenario Outline: enter basic data for <state> registrant
      Given I have completed step 2 as a resident of "<state>" state
      And I have a state license
      When I go to the step 3 page
      Then I should see a checkbox for "Send me txt messages from Rock the Vote"
      And I should see a checkbox for "Receive emails from Rock the Vote"
      And I press "registrant_submit"
      Then I should see "<message>"

      Examples:
        | state      | message             |
        | Washington | Hang on. You are eligible to register online in your state. |
        | Arizona    | Hang on. You are eligible to register online in your state. |
        | Colorado   | Hang on. You are eligible to register online in your state. |
        | Nevada     | Hang on. You are eligible to register online in your state. |
        
        
    @passing
    Scenario: CA resident NOT eligible for OVR submits step 3 and goes to regular step 4
      Given I have completed step 2 as a resident of "California" state
      When I go to the step 3 page
      And I press "registrant_submit"
      Then I should see "Additional Registration Information"
    
        
    @passing
    Scenario: CA resident eligible for OVR submits step 3 with UI debugging on
      Given I have completed step 2 as a resident of "California" state
      And I have a state license
      And COVR UI debugging is true
      When I go to the step 3 page
      And I press "registrant_submit"
      Then I should see the return XML from the API request

    @passing
    Scenario: CA resident eligible for OVR submits step 3 and is not approved
      Given I have completed step 2 as a resident of "California" state
      And I have a state license
      And COVR UI debugging is false
      And COVR responses return failures
      When I go to the step 3 page
      And I press "registrant_submit"
      Then I should see "Additional Registration Information"
      And I should not see "Hang on. You are eligible to register online in your state."
      
    @passing
    Scenario: CA resident eligible for OVR submits step 3 and is approved
      Given I have completed step 2 as a resident of "California" state
      And I have a state license
      And COVR UI debugging is false
      And COVR responses return successes
      When I go to the step 3 page
      And I press "registrant_submit"
      Then I should see "Hang on. You are eligible to register online in your state."
      And I should see "TBD 5 CA Disclosures"
      And I should see a checkbox for "registrant_attest_true"
      

