Feature: Finish
  In order to complete voter registration
  As a registrant
  I want to download reg form PDF

    @cleanup_pdf
    Scenario: download form
     Given I have completed step 4
      When I go to the step 5 page
       And I check "registrant_attest_true"
       And I press "registrant_submit"
      When I go to the download page
      Then I should see a new download
