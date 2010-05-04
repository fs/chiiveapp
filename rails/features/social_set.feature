Feature: Social Set JSON Interface
	In order see and edit social sets
	As a Qamio remote client user
	I want to create, update, and view a social set
	
	Scenario: View an event
		Given a social_set exists with title "Hot Diggity!"
		# And the event was created by Chiive user "John Smith"
		# And the event has 4 images
		# And the event has 3 attendees
		# And the event has 2 comments
		And I am on the social_set page for this social_set
		Then I should see "Hot Diggity"
		# And I should see "John Smith"
