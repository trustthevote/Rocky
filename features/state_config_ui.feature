Feature: State Config UI
  
  So that admins can manage state settings
  As an admin 
  I want to manage state data to produce a new states.yml file
  
  Background:
    Given I override the states yml file
    And I override the tmp state_config file path and clear them
  
  
  @passing
  Scenario: Index page shows all state settings
    When I go to the state configurations page
    Then I should see default state settings
    And I should see all state settings
    
  @passing
  Scenario: Submitting the state configs
    When I go to the state configurations page
    And I press "Save and Email Configurations"
    Then I should see "Thanks! Your state config changes have been submitted."
    And a tmp state_config file should be created
    And there should be an email sent with an attachment
      