Feature: Translation UI
  
  So that translators can provide translations for all keys
  As a translator 
  I want to enter translations for all keys in the system.
  
    Background:
      Given I override the states I18n file for english and spanish
      And I override the set of available locales
      And I override the tmp translation file path and clear them
  
    @passing
    Scenario: Translator sees all language and type combinations
      When I go to the translations page
      Then I should see all languages and types
      
      
    @passing
    Scenario: Translator views the states group in spanish
      # should see all the states/.yml values
      # should see key-value chains for each item
      # should see instructions around interpolation variables
      When I go to the es states translation page
      Then I should see all the keys from the english states/en.yml
      And I should see the full key name for each english states item
      And I should see the english value for each english states item
      And I should see instructions for interpolation variables
      And I should see instructions provided in the english file
    
    #_translation_instructions values are hidden from UI - must be entered manually
    @passing
    Scenario: Translator views the states group in english  
      When I go to the en states translation page
      Then I should see "Please keep '%{variable}' intact"
      And I should see "states.testing.val1"
      And I should not see "states.testing.val1_translation_instructions"
      And I should see "states.testing.val2"
      
    @passing
    Scenario: Translator saves the states group in spanish with missing translations
      When I go to the es states translation page
      And I fill in "es[states.testing.val1]" with ""
      And I press "Save Translations"
      Then I should see "The following items are missing translations: states.testing.val1"
      And a tmp translation file should be created
      
    
    @passing
    Scenario: Translator submits the states group in spanish with missing translations
      When I go to the es states translation page
      And I fill in "es[states.testing.val1]" with ""
      And I press "Submit Translations"
      Then I should see "The following items are missing translations: states.testing.val1"
      And I should see "Translations were NOT submitted due to errors."
      And a tmp translation file should be created
      And there should not be an email sent
      
    
    @passing
    Scenario: Translator submits the states group in spanish with missing interpolation variables
      When I go to the es states translation page
      And I fill in "es[states.testing.val1]" with "Removed the interpolation variable"
      And I press "Submit Translations"
      Then I should see "The following items are missing %{VARIABLE} substitutions: states.testing.val1"
      And I should see "Translations were NOT submitted due to errors."
      And a tmp translation file should be created
      And there should not be an email sent
    
    @passing
    Scenario: Translator submits a states group with no errors
      When I go to the es states translation page
      And I fill in "es[states.testing.val1]" with "Cambio - %{variable}"
      And I press "Submit Translations"
      Then I should see "Thanks! Your translations have been submitted."
      And a tmp translation file should be created
      And there should be an email sent with an attachment
      
