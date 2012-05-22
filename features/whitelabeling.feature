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
    
    @wip-l
    Scenario: Uploading a zip to create new partners
    
    @wip-l
    Scenario: Uploading a zip with missing required assets
    
    @wip-l
    Scenario: Uploading a zip with an invalid partner record
    
    @wip-l
    Scenario: Uploading a zip with a duplicate email/login for a partner record
    
    
    # TODO:
    # write email scenarios
    # 
    # MODELING:
    # 
    # * set up default values for existing fields (true for rtv-opt, false for partner-opt, false for registrants)
    # 
    # * whitelabeled partner has methods for checking if email templates are there
    # * partners can be configured to use special email templates 
    # Q: only if whitelabeled in general?
    # 
    # * if configured, make emails to users use partner-specific email templates
    
    