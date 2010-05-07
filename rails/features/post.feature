Feature: Post Create, View, and Update
	In order to see and manipulate posts
	As a Qamio user
	I want to create, view, edit, and update posts
	
	Scenario: Create a new post
		Given I am logged in as "admin@chiive.com" with password "secret"
		And I am on the new post page
		When I fill in "post[latitude]" with "1.0"
		When I press "Save"
		Then I should see "Harry"
		And I should see "Newguy"
		And I should not see "Role:"

	