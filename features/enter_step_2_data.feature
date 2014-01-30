Feature: Step 2
  In order to provide personal information
  As a registrant
  I want to enter name, address, changes and contact info (phone)
  
    @passing
    Scenario: first visit
      Given I have completed step 1
      When I go to the step 2 page
      And I select "Mr." from "Title"
      And I fill in "First" with "John"
      And I fill in "Last" with "Public"
      And I fill in "Address" with "123 Market St."
      And I fill in "City" with "Pittsburgh"
      And I fill in "Phone" with "415-555-4254"
      And I press "registrant_submit"
      Then I should see "Additional Registration Information"

    @passing
    Scenario: first time registrant
      Given I have completed step 1
      And I am a first time registrant
      When I go to the step 2 page
      Then I should not see "I have changed my name"
      And I should not see "I have changed my address"

    @passing
    Scenario: changing name
      Given I have completed step 1
      When I go to the step 2 page
      And I check "I have changed my name"
      And I select "Mr." from "registrant_prev_name_title"
      And I fill in "registrant_prev_first_name" with "First"
      And I fill in "registrant_prev_last_name" with "Last"
      And I select "Mr." from "Title"
      And I fill in "First" with "John"
      And I fill in "Last" with "Public"
      And I fill in "Address" with "123 Market St."
      And I fill in "City" with "Pittsburgh"
      And I press "registrant_submit"
      Then I should see "Additional Registration Information"

    @passing
    Scenario: changing address
      Given I have completed step 1
      When I go to the step 2 page
      And I check "I have changed my address"
      And I fill in "registrant_prev_address" with "123 Market St."
      And I fill in "registrant_prev_city" with "Pittsburgh"
      And I select "Pennsylvania" from "registrant_prev_state_abbrev"
      And I fill in "registrant_prev_zip_code" with "15215"
      And I select "Mr." from "Title"
      And I fill in "First" with "John"
      And I fill in "Last" with "Public"
      And I fill in "Address" with "123 Market St."
      And I fill in "City" with "Pittsburgh"
      And I press "registrant_submit"
      Then I should see "Additional Registration Information"
    
    @passing
    Scenario: default prev state to home state
      Given I have completed step 1
      When I go to the step 2 page
      Then I should see "Pennsylvania" in select box "registrant_prev_state_abbrev"

     
    @passing  
    Scenario: default mailing state to home state
      Given I have completed step 1
      When I go to the step 2 page
      Then I should see "Pennsylvania" in select box "registrant_mailing_state_abbrev"
  
    
    
    
    @passing
    Scenario: User arrives with short_form=1
      Given I have completed step 1 for a short form
      When I go to the step 2 page
      And I should see a field for "Title"
      And I should see a field for "First"
      And I should see a field for "Middle"
      And I should see a field for "Last"
      And I should see a field for "Suffix"
      And I should see a field for "Address"
      And I should see a field for "registrant_home_unit"
      And I should see a field for "City"
      And I should see a field for "State"
      And I should see a field for "ZIP Code"
      And I should see a checkbox for "registrant_has_mailing_address"
      And I should see a field for "I have changed my name"
      And I should see a field for "I have changed my address"      
      And I should see a field for "registrant_state_id_number"
      And I should see a field for "Race"
      And I should see a field for "Phone"
      And I should see a field for "Type"
      And I should see a field for "Send me txt messages from Rock the Vote"
      And I should see a field for "Receive emails from Rock the Vote"
      
      
    @passing
    Scenario: User arrives with short_form=1 for a state with an online system
      Given I have completed step 1 for a short form as a resident of "California"
      And I have a state license
      When I go to the step 2 page
      And I select "Mr." from "Title"
      And I fill in "First" with "John"
      And I fill in "Last" with "Public"
      And I fill in "Phone" with "1231231234"
      And I fill in "Address" with "123 Market St."
      And I fill in "City" with "Pittsburgh"
      And I press "registrant_submit"
      Then I should see "Additional Registration Information"
      And I should see a field for "Send me txt messages from Rock the Vote"
      And I should see a field for "Receive emails from Rock the Vote"
      
    @passing
    Scenario: User arrives with short_form=1 and leaves fields blank
      Given I have completed step 1 for a short form
      When I go to the step 2 page
      And I press "registrant_submit"
      Then I should see "Personal Information"
      And I should see "Required"
      
    @passing
    Scenario: User arrives with short_form=1 and fills all required fields
      Given I have completed step 1 for a short form
      When I go to the step 2 page
      And I select "Mr." from "Title"
      And I fill in "First" with "John"
      And I fill in "Last" with "Public"
      And I fill in "Address" with "123 Market St."
      And I fill in "City" with "Pittsburgh"
      And I fill in "ID Number" with "1234"
      And I select "Hispanic" from "Race"
      And I select "Democratic" from "Party"
      And I press "registrant_submit"
      Then I should see "Print Your Form"

      