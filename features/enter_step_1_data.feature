Feature: Step 1
  In order to establish eligibility
  As a registrant
  I want to enter step 1 data

    Scenario: start
      When I go to a new registration page
      Then I should see "New Registrant"

    @passing
    Scenario: Start from a mobile agent
      Given I am using a mobile browser
      When I go to a new registration page
      Then I should be redirected to the mobile url with partner="1"
      
    @passing
    Scenario: Start from a mobile agent and partner setting
      Given I am using a mobile browser
      And the following partner exists:
        | organization |
        | one          |
        | two          |
        | th3          |
      When I go to a new registration page for partner="3"
      Then I should be redirected to the mobile url with partner="3"

    @passing
    Scenario: Start from a mobile agent and partner, source and tracking setting
      Given I am using a mobile browser
      And the following partner exists:
        | organization |
        | one          |
        | two          |
        | th3          |
      When I go to a new registration page for partner="3", source="abc" and tracking="def"
      Then I should be redirected to the mobile url with partner="3", source="abc" and tracking="def"

    Scenario: start in Spanish
      When I go to a new Spanish registration page
      Then I should not see "^New Registrant"
       And I should see "Nuevo Registro"

    Scenario: completing step 1
      When I go to a new registration page
       And I have not set a locale
       And I fill in "email address" with "john.public@example.com"
       And I fill in "zip code" with "94113"
       And I am 20 years old
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

    Scenario: modifying step 1 data
      Given I have completed step 4
      When I go to the step 1 page
      Then I should see my email
       And I should see my date of birth
       
    Scenario: Step1 creation default for primary partner
      When I go to a new registration page
      And I fill in "email address" with "john.public@example.com"
      And I fill in "zip code" with "94113"
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
      And I fill in "email address" with "john.public@example.com"
      And I fill in "zip code" with "94113"
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
        