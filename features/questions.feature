Feature: Questions
  In order to create or update survey questions
  A partner
  Enters questions on edit page

    Scenario: Partner can edit questions
      Given I am logged in as a valid partner
        And I am on the partner dashboard page
      Then I should see "Hello?"
        And I follow "Edit Questions"
        And I should see "Survey Questions"
        And I fill in "Question 1, English" with "What is your quest?"
        And I press "Submit"
        And I should see "You have updated your survey questions"
        And I should see "What is your quest?"
