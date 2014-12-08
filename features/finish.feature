Feature: Finish
  In order to complete voter registration
  As a registrant
  I want to download reg form PDF

    @cleanup_pdf @passing
    Scenario: download form
     Given I have completed step 4
      When I go to the step 5 page
       And I check "registrant_attest_true"
       And I press "registrant_submit"
      When I go to the download page
      Then I should see a new download

    @passing
    Scenario: preparing form
     Given I have completed step 5
       And the PDF is not ready
      When I go to the download page
      Then I should see "Preparing Registration Form"
