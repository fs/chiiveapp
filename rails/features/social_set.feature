Feature: Social Set JSON Interface
	In order see and edit social sets
	As a Qamio remote client user
	I want to create, update, and view a social set
	
	Scenario: View a social_set
		Given I am logged in as "admin@chiive.com" with password "secret"
		And a social_set exists
		And the social_set has title "Hot Diggity!"
		And the social_set was created by user "John Smith"
		And the social_set has 4 posts
		And the social_set has 2 attendees
		And the social_set has 2 comments
		And I am on the social_set's page
		Then I should see "Hot Diggity"
		And I should see "John Smith"
		
	Scenario: Create a social_set
		Given I am logged in as "admin@chiive.com" with password "secret"
		And I am on the new social_set page
		When I fill in "social_set[personal_sets_attributes][0][title]" with "Hello Dolly!"
		And I fill in "social_set[personal_sets_attributes][0][latitude]" with "123"
		And I fill in "social_set[personal_sets_attributes][0][longitude]" with "321"
		And I press "Save"
		Then I should see "Hello Dolly!"
		And a personal_set should exist with title: "Hello Dolly!"
		And a social_set should exist with latitude: 123, longitude: 321
	
	# Scenario: Update a social_set
	# 	Given I am logged in as "admin@chiive.com" with password "secret"
	# 	And a social_set exists
	# 	And I am on that social_set's edit page
	# 	When I fill in "social_set[personal_sets_attributes][0][title]" with "This is a new title!"
	# 	And I press "Save"
	# 	Then I should see "This is a new title!"
	# 	And a personal_set should exist with title "This is a new title!"
	