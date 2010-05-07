Feature: Social Set JSON Interface
	In order see and edit social sets
	As a Qamio remote client user
	I want to create, update, and view a social set
	
	Scenario: View an event
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
		