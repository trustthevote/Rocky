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
        | Washington | You may be eligible |
        | Arizona    | You may be eligible |
        | Colorado   | You may be eligible |
        | Nevada     | You may be eligible |
        
        
        
    @wip
    Scenario: CA resident eligible for OVR submits step 3
      Given I have completed step 2 as a resident of "California" state
      And I have a state license
      And COVR UI debugging is true
      When I go to the step 3 page
      And I press "registrant_submit"
      Then I should see the return XML from the API request
      
      
      
      
    