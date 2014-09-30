Feature: White labeling

  So that partners can have custom UIs
  As an site visitor
  I should be see custom designs for partners configured with white labeling assets
  
  
    Scenario: Partner with ID 1 should use the standard assets
      Given the following partner exists:
        | id | name                | whitelabeled |
        |  1 | Standard UI Partner | false        |
      And that partner's css file exists  
      When I go to the registration page for that partner
      Then I should see a link to the standard CSS
  
    Scenario: Partner without custom css should use the standard assets
      Given the following partner exists:
        | name                | whitelabeled |
        | Standard UI Partner | false        |
      When I go to the registration page for that partner
      Then I should see a link to the standard CSS
  
    Scenario: Whitelabeled partner with missing CSS should use the standard assets
      Given the following partner exists:
        | name                | whitelabeled |
        | Standard UI Partner | true        |
      And that partner's css file does not exist
      When I go to the registration page for that partner
      Then I should see a link to the standard CSS
 
    
    Scenario: Whitelabeled partner with assets should use the custom CSS
      Given the following partner exists:
        | name                | whitelabeled |
        | Standard UI Partner | true         |
      And that partner's css file exists
      When I go to the registration page for that partner
      Then I should see a link to that partner's CSS
    
    
    
    