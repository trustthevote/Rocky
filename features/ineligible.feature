Feature: Ineligible
  As a registrant
  I want to be denied when I am ineligible
  In order to move on

    Scenario: state doesn't register
     Given I go to a new registration page
       And I enter valid data for step 1
       But I live in North Dakota
      When I press "registrant_submit"
      Then I should see "not eligible"
       And I should see "North Dakota does not register voters"
      When I follow "Return"
       And I live in California
       And I press "registrant_submit"
      Then I should see "Personal Information"
      
    Scenario: too young
     Given I go to a new registration page
       And I enter valid data for step 1
       But I am 15 years old
      When I press "registrant_submit"
      Then I should see "not eligible"
       And I should see "must be 16 years old"
      When I follow "Return"
       And I am 18 years old
       And I press "registrant_submit"
      Then I should see "Personal Information"

    Scenario: not citizen
     Given I go to a new registration page
       And I enter valid data for step 1
       But I uncheck "I am a U.S. citizen"
      When I press "registrant_submit"
      Then I should see "not eligible"
       And I should see "must be a U.S. citizen"
      When I follow "Return"
       And I check "I am a U.S. citizen"
       And I press "registrant_submit"
      Then I should see "Personal Information"

    Scenario: didn't affirm truth
     Given I have completed step 4
      When I go to the step 5 page
       And I select "Yes" from "registrant_attest_eligible"
       But I select "No" from "registrant_attest_true"
      When I press "registrant_submit"
      Then I should see "not eligible"
       And I should see "confirm you are eligible"
      When I follow "Return"
       And I select "Yes" from "registrant_attest_true"
       And I press "registrant_submit"
      Then I should see "Download"
      
    Scenario: didn't affirm eligible
     Given I have completed step 4
      When I go to the step 5 page
       And I select "Yes" from "registrant_attest_true"
       But I select "No" from "registrant_attest_eligible"
      When I press "registrant_submit"
      Then I should see "not eligible"
       And I should see "confirm you are eligible"
      When I follow "Return"
       And I select "Yes" from "registrant_attest_eligible"
       And I press "registrant_submit"
      Then I should see "Download"

    Scenario: multiple reasons on same page
     Given I go to a new registration page
       And I enter valid data for step 1
       But I am 15 years old
       And I live in North Dakota
      When I press "registrant_submit"
      Then I should see "not eligible"
       And I should see "must be 16 years old"
       And I should see "North Dakota does not register voters"
      When I follow "Return"
       And I am 18 years old
       And I live in California
       And I press "registrant_submit"
      Then I should see "Personal Information"
