Feature: Translation UI
  
  So that translators can provide translations for all keys
  As a translator 
  I want to enter translations for all keys in the system.
      
    @passing
    Scenario: Translator previews DPF
      When I go to the en translations pdf preview page
      Then I should get a PDF
    