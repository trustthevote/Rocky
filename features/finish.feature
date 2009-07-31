Feature: Finish
  In order to complete voter registration
  As a registrant
  I want to download reg form PDF

    Scenario: download form
     Given I have completed step 5
       And I have not downloaded the PDF before
      When I go to the download page
       And I follow "Download PDF!"
      Then I should see a new download
