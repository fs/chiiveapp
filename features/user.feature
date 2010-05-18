Feature: User Create, View, and Update
	In order to see and manipulate user account
	As a Qamio user
	I want to create, view, edit, and update user account info
	
	Scenario: Create a new account
		Given I am on the new user page
		Then I should see "Register"
		When I fill in "user[email]" with "user@chiive.com"
		And I fill in "user[password]" with "password123"
		And I fill in "user[password_confirmation]" with "password123"
		And I fill in "First Name" with "Harry"
		And I fill in "Last Name" with "Newguy"
		When I press "Save"
		Then I should see "Harry"
		And I should see "Newguy"
		And I should not see "Role:"
	
	Scenario: View a user's account
		Given a user exists with first_name: "Harry", last_name: "Sally", email: "harry@sally.com", password: "pass123", roles_mask: 1
		And I am on the login page
		And I fill in "user_session[login]" with "harry@sally.com"
		And I fill in "user_session[password]" with "pass123"
		When I press "Log In"
		When I go to that user's page
		Then I should see "Harry"
		And I should see "Sally"
		And I should not see "harry@sally.com"
		And I should not see "pass123"
		
	Scenario: Update an admin user's account
		Given a user exists with first_name: "Harry", last_name: "Sally", email: "harry@sally.com", password: "pass123", roles_mask: 1
		And I am on the login page
		And I fill in "user_session[login]" with "harry@sally.com"
		And I fill in "user_session[password]" with "pass123"
		When I press "Log In"
		When I go to the user's edit page
		Then I should see "Harry"
		When I fill in "user[first_name]" with "Harold"
		And I press "Save"
		Then I should be on the user's page
		And I should see "Harold"
		And I should not see "Save"
		
	Scenario: Update another user's role as an admin
		Given I am logged in as "admin@chiive.com" with password "secret"
		And a user exists with first_name: "Harry", roles_mask: 0
		And I am on the user's edit page
		Then I should see "Harry"
		And I should see "Role"
		When I check "role[admin]"
		And I press "Save"
		Then I should be on the user's page
		And I should see "Harry"
		And I should see "Role: Admin"