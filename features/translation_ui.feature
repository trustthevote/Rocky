Feature: Admin UI
  
  So that translators can provide translations for all keys
  As a translator 
  I want to enter translations for all keys in the system.
  
    Background:
      Given I override the states I18n file for english and spanish
  
    @wip
    Scenario: Translator sees all language and type combinations
      When I go to the translations page
      Then I should see all languages and types
      
      
    @wip
    Scenario: Translator views the states group in spanish
      # should see all the states/.yml values
      # should see key-value chains for each item
      # should see instructions around interpolation variables
      When I go to the spanish states translation page
      Then I should see all the keys from the english states/en.yml
      And I should see the full key name for each item
      And I should see the english value for each item
      And I should see instructions for interpolation variables
      And I should see instructions provided in the english file
    
    #_translation_instructions values
    Scenario: Translator views the states group in english  
      
    Scenario: Translator saves the states group in spanish with missing translations
    
    Scenario: Translator submits the states group in spanish with missing translations
    
    Scenario: Translator submits the states group in spanish with missing interpolation variables
    
    Scenario: Translator submits a states group with no errors