Feature: Step 2
  In order to provide personal information
  As a registrant
  I want to enter name, address
  
    Scenario: do not have mailing address
      Given I have completed step 1
      When I go to the step 2 page
      Then I should not see "Mailing Address"

    Scenario: have mailing address
      Given I have completed step 1
      When I go to the step 2 page
       And I check "I get my mail at a different address from the one above"
      Then I should see "Mailing Address"
