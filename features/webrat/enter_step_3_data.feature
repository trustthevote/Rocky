Feature: Step 3
  In order to provide id and changes
  As a registrant
  I want to enter id, phone and changes
  
    Scenario: first time registrant
      Given I have completed step 2
       And I am a first time registrant
      When I go to the step 3 page
       And I fill in "ID Number" with "1234"
       And I press "Submit"
      Then I should see "Gotcha"
    # 
    # Scenario: changing registration
    #   Given I have completed step 2
    #    And I am not a first time registrant
    #   When I go to the step 3 page
    #    And I fill in "ID Number" with "1234"
    #    And I check "My name has changed"
    #    And I select "Mr." from "title"
    #    And I fill in "first" with "John"
    #    And I fill in "last" with "Public"
    #    And I press "Submit"
    #   Then I should see "Gotcha"
