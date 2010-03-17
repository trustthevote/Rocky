Feature: Finish
  In order to finish
  As a registrant
  I want to spread the word

    @cleanup_pdf
    Scenario: finishing up
     Given I have completed step 4
      When I go to the step 5 page
       And I check "registrant_attest_true"
       And I press "registrant_submit"
      When I go to the download page
      Then I should see a new download
      When I follow "Download PDF!"
       And I ignore the new blank window
      Then I should see "Spread the word!"
