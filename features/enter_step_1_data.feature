Feature: Step 1
  In order to establish eligibility
  As a registrant
  I want to enter step 1 data

    Scenario: start
      When I go to a new registration page
      Then I should see "New Registrant"

    Scenario: start in Spanish
      When I go to a new Spanish registration page
      Then I should not see "^New Registrant"
       And I should see "Nuevo Registro"
       
    @passing
    Scenario: Start in language with an external stylesheet
      Given there is a stylesheet for Spanish
      When I go to a new Spanish registration page
      Then the Spanish style sheet should be included
      
    @passing
    Scenario: Start in language without an external stylesheet
      Given there is not a stylesheet for Spanish
      When I go to a new Spanish registration page
      Then the Spanish style sheet should not be included
       
    @passing
    Scenario: start in Korean
      When I go to a new Korean registration page
      Then I should not see "^New Registrant"
      And I should see " 새로운 유권자"

    @passing
    Scenario: Form includes email address
      When I go to a new registration page
      Then I should see a field for "Email Address"
      
    @passing
    Scenario Outline: Form includes email address when collectemailaddress is <value>
       When I go to a new registration page with collectemailaddress="<value>"
       Then I <should_or_not> see a field for "Email Address"
    
       Examples:
         | value     | should_or_not |
         | yes       | should        |
         | Yes       | should        |
         | YES       | should        |
         | optional  | should        |
         | Optional  | should        |
         | OPTIONAL  | should        |
         | abc       | should        |
         | no        | should not    |
         | NO        | should not    |
         | No        | should not    |
         | nO        | should not    |
         
    
    @wip
    Scenario: completing step 1
      When I go to a new registration page
       And I have not set a locale
       And I fill in "Email Address" with "john.public@example.com"
       And I fill in "ZIP Code" with "94113"
       And I am 20 years old
       And I check "registrant_has_state_license"
       And I check "registrant_will_be_18_by_election"
       And I check "I am a U.S. citizen"
       And I press "registrant_submit"
      Then I should see "Personal Information"

    Scenario: completing step 1 in Spanish
      When I go to a new Spanish registration page
       And I have not set a locale
       And I fill in "registrant_email_address" with "john.public@example.com"
       And I fill in "registrant_home_zip_code" with "94113"
       And I am 20 years old
       And I check "registrant_us_citizen"
       And I press "registrant_submit"
      Then I should not see "^Personal Information"
       And I should see "Información Personal"
    
    @passing
    Scenario: completing step 1 in Korean
      When I go to a new Korean registration page
       And I have not set a locale
       And I fill in "registrant_email_address" with "john.public@example.com"
       And I fill in "registrant_home_zip_code" with "94113"
       And I am 20 years old
       And I check "registrant_us_citizen"
       And I press "registrant_submit"
      Then I should not see "^Personal Information"
       And I should see " 개인 정보"
    

    Scenario: modifying step 1 data
      Given I have completed step 4
      When I go to the step 1 page
      Then I should see my email
       And I should see my date of birth
       
    @passing
    Scenario: External snippet for a partner
      Given the following partner exists:
        | organization   | external_tracking_snippet   |
        | Opt-in Partner | Custom Snippet From Partner |
      When I go to a new registration page for that partner
      Then I should see "Custom Snippet From Partner"
        
      
    Scenario: Step1 creation default for primary partner
      When I go to a new registration page
      And I fill in "Email Address" with "john.public@example.com"
      And I fill in "ZIP Code" with "94113"
      And I am 20 years old
      And I check "I am a U.S. citizen"
      And I press "registrant_submit"
      Then my value for "opt_in_email" should be "true"
      And my value for "opt_in_sms" should be "true"
      And my value for "volunteer" should be "false"
      And my value for "partner_opt_in_email" should be "false"
      And my value for "partner_opt_in_sms" should be "false"
      And my value for "partner_volunteer" should be "false"

    Scenario Outline: Step1 creation opt-in defaults for partners   
       Given the following partner exists:
         | organization   | rtv_email_opt_in | rtv_sms_opt_in | ask_for_volunteers | partner_email_opt_in | partner_sms_opt_in | partner_ask_for_volunteers   |  
         | Opt-in Partner | <rtv_email>      | <rtv_sms>      | <rtv_volunteer>    | <partner_email>      | <partner_sms>      | <partner_ask_for_volunteers> |        
      When I go to a new registration page for that partner
      And I fill in "Email Address" with "john.public@example.com"
      And I fill in "ZIP Code" with "94113"
      And I am 20 years old
      And I check "I am a U.S. citizen"
      And I press "registrant_submit"
      Then my value for "opt_in_email" should be "<rtv_email>"
      And my value for "opt_in_sms" should be "<rtv_sms>"
      And my value for "volunteer" should be "false"
      And my value for "partner_opt_in_email" should be "<partner_email>"
      And my value for "partner_opt_in_sms" should be "<partner_sms>"
      And my value for "partner_volunteer" should be "false"

      Examples:
        | rtv_email | rtv_sms | rtv_volunteer | partner_email | partner_sms | partner_ask_for_volunteers |
        | true      | true    | true          | true          | true        | true                       |
        | true      | false   | false         | false         | true        | false                      |
        | false     | true    | true          | true          | false       | true                       |
        | false     | false   | false         | false         | false       | false                      |
        | false     | false   | false         | false         | false       | false                      |
        | true      | false   | false         | false         | false       | false                      |
        | false     | true    | false         | false         | false       | false                      |
        | false     | false   | true          | false         | false       | false                      |
        | false     | false   | false         | true          | false       | false                      |
        | false     | false   | false         | false         | true        | false                      |
        | false     | false   | false         | false         | false       | true                       |
        