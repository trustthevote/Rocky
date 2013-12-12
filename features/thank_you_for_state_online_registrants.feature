Feature: Thank you email for registrants who choose to register online with a state system

  So that RTV can communicate with users who finish their registrations with another system
  As a system
  I want to track users who end up on the state online system and don't come back to RTV and send them thank-you emails
  
  @passing
  Scenario: Registrant goes to the state online registration page
    Given I have completed step 1 as a resident of "Washington" state
    When I go to the step 2 page
    And I select "Mr." from "Title"
    And I fill in "First" with "John"
    And I fill in "Last" with "Public"
    And I choose "I have a current WA state identification card or driver's license"
    And I press "registrant_state_online_registration"
    Then I should be recorded as having selected to finish with the state
  
  @passing
  Scenario Outline: Registrant who was on the state online registration page goes to step <step> registration page
    Given I have been to the state online registration page
    When I go to the step <step> page
    Then I should not be recorded as having selected to finish with the state
    
    Examples:
      | step | 
      | 1    |
      | 2    |
      | 3    |
  
  @passing
  Scenario: Registrant who finished online gets sent a thank-you email
    Given I have completed step 1 as a resident of "Washington" state
    When I go to the step 2 page
    And I select "Mr." from "Title"
    And I fill in "First" with "John"
    And I fill in "Last" with "Public"
    And I choose "I have a current WA state identification card or driver's license"
    And I press "registrant_state_online_registration"
    And my session expires
    And the timeout_stale_registrations task has run
    Then I should be sent a thank-you email
    And my status should be "complete"

  @passing
  Scenario: Registrant from a whitelabeled partner who finished online gets sent a thank-you email from that partner
    Given the following partner exists:
      | organization   | rtv_sms_opt_in | partner_sms_opt_in | from_email                      | whitelabeled |
      | Opt-in Partner | true           | true               | alexmek+partner-email@gmail.com | true         |
    Given I have completed step 1 as a resident of "Washington" state from that partner
    When I go to the step 2 page
    And I select "Mr." from "Title"
    And I fill in "First" with "John"
    And I fill in "Last" with "Public"
    And I choose "I have a current WA state identification card or driver's license"
    And I press "registrant_state_online_registration"
    And my session expires
    And the timeout_stale_registrations task has run
    Then I should be sent a thank-you email from that partner
    And my status should be "complete"
    
  @passing
  Scenario: Registrant from a non-whitelabeled partner who finished online gets sent a thank-you email from RTV
    Given the following partner exists:
      | organization   | rtv_sms_opt_in | partner_sms_opt_in | from_email                      | whitelabeled |
      | Opt-in Partner | true           | true               | alexmek+partner-email@gmail.com | false        |
    Given I have completed step 1 as a resident of "Washington" state from that partner
    When I go to the step 2 page
    And I select "Mr." from "Title"
    And I fill in "First" with "John"
    And I fill in "Last" with "Public"
    And I choose "I have a current WA state identification card or driver's license"
    And I press "registrant_state_online_registration"
    And my session expires
    And the timeout_stale_registrations task has run
    Then I should be sent a thank-you email from RTV
    And my status should be "complete"


  @passing
  Scenario: Registrant who finished online and selected spanish gets sent a thank-you email
    Given I have completed step 1 as a resident of "Washington" state
    And my locale is "es"
    When I go to the step 2 page
    And I select "Sr." from "Titulo"
    And I fill in "Nombre" with "John"
    And I fill in "Apellido" with "Public"
    And I choose "registrant_has_state_license_1"
    And I press "registrant_state_online_registration"
    And my session expires
    And the timeout_stale_registrations task has run
    Then I should be sent a thank-you email in spanish
    And my status should be "complete"
    
  @passing
  Scenario: Registrant who finished online and selected korean gets sent a thank-you email
    Given I have completed step 1 as a resident of "Washington" state
    And my locale is "ko"
    When I go to the step 2 page
    And I select "Mr." from "registrant_name_title"
    And I fill in "registrant_first_name" with "John"
    And I fill in "registrant_last_name" with "Public"
    And I choose "registrant_has_state_license_1"
    And I press "registrant_state_online_registration"
    And my session expires
    And the timeout_stale_registrations task has run
    Then I should be sent a thank-you email in korean
    And my status should be "complete"

    
  @passing
  Scenario: Registrant who finished online but hasn't expired yet doesn't get sent a thank-you email
    Given I have completed step 1 as a resident of "Washington" state
    When I go to the step 2 page
    And I select "Mr." from "Title"
    And I fill in "First" with "John"
    And I fill in "Last" with "Public"
    And I choose "I have a current WA state identification card or driver's license"
    And I press "registrant_state_online_registration"
    And the timeout_stale_registrations task has run
    Then I should not be sent a thank-you email
    And my status should not be "complete"

  @passing
  Scenario: Registrant who at one point finished online but went back to the RTV form and had their session expire doesn't get sent a thank you email
    Given I have completed step 1 as a resident of "Washington" state
    When I go to the step 2 page
    And I select "Mr." from "Title"
    And I fill in "First" with "John"
    And I fill in "Last" with "Public"
    And I choose "I have a current WA state identification card or driver's license"
    And I press "registrant_state_online_registration"
    And I follow "finish your registration with Rock the Vote"
    And my session expires
    And the timeout_stale_registrations task has run
    Then I should not be sent a thank-you email
    And my status should not be "complete"
  
  
  
  