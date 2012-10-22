Feature: Admin gregistrations

  So I can manage government partners
  As an admin
  I want to view, create and edit government partners in the admin UI
  
    Scenario: Government partner lists
      Given the following government partner exists:
        | organization                 |
        | Government Organization Name |
      When I go to the admin dashboard
      And I follow "Government Partners"
      Then I should see "Government Organization Name"
      And I should see a link for "Standard Partners"


    Scenario: Create a new government partner
      When I go to the admin government partners page
      And I follow "Create New Government Partner"
      Then I should not see a field for "Username"
      And I should not see a field for "Password"
      And I should not see a field for "Password Confirmation"
      And I should see a field for "From Email"
      And I should see a field for "Finish iframe url"
      And I should see a field for "Whitelabeled CSS"
      And I should see a field for "Ask for RTV email opt-in"
      And I should see a field for "Ask for RTV SMS opt-in"
      And I should see a field for "Ask for RTV Volunteers"
      And I should see a field for "Ask for partner email opt-in"
      And I should see a field for "Ask for partner SMS opt-in"
      And I should see a field for "Ask for partner Volunteers"
      When I fill in "Name" with "Contact Name"
      And I fill in "Address" with "123 Main St"
      And I fill in "City" with "Boston"
      And I select "Massachusetts" from "State"
      And I fill in "Zip" with "02110"
      And I fill in "Organization" with "Government Partner Organization Name"
      And I fill in "URL" with "http://www.google.com"
      And I fill in "Phone" with "1234567890"
      And I fill in "Email" with "email@example.com"
      And I press "Save"
      Then I should be on the admin government partners page
      And I should see "Government Partner Organization Name"
