Feature: Facebook Event Page
	In order to see a Facebook event page
	As a facebook user
	I want to view photos and people, make comments, and share
	
  Scenario: View an event
    Given I have an event named "Hot Diggity!"
    And the event was created by Chiive user "John Smith"
    And the event has 4 images
    And the event has 3 attendees
    And the event has 2 comments
    When I go to the event page for the event
    Then I should see "Hot Diggity"
    And I should see "John Smith"
    And I should see the avatar image of "John Smith"
    And I should see a "Post" link to post a comment
    And I should see a "Share" link to share the event
    And I should see "4 photos"
    And I should see "3 people"
    And I should see 4 thumbnail images
    And I should see 3 attendee names
    And I should see 2 comments
    And I should not see thumbnail pagination
    And I should not see user pagination
    
  Scenario: Comment on the event
    Given I am a Chiive user "Carol Oates", and avatar image "carol_oats_avatar.jpg"
    And I have connected my Facebook Account with uid "123123" to my Chiive account
    And I have an event named "Hot Diggity!"
    And I am on the event page for the event
    When I fill in "comment[body]" with "I like this event"
    And I press "Post"
    And I go to the event page for the event
    # Then I should be on the event page for the event
    Then I should see "Hot Diggity!"
    And a comment should exist with body "I like this event"
    And I should see "I like this event"
    And I should see facebook name for "123123"
    And I should see facebook avatar for "123123"
    And I should see "Delete"
  
  Scenario: View a photo
    Given I have an event named "Hot Diggity!"
    And the event was created by Chiive user "John Smith"
    And the event has post with title "Check out who just arrived!" posted on "04/29/2010" by "Huey Lewis"
    And the event has 3 attendees
    And the post has 2 comments
    When I go to the post page for the post
    Then I should see "Hot Diggity"
    And I should see "John Smith"
    And I should see the avatar image of "John Smith"
    And I should see a "Post" link to post a comment
    And I should see a "Share" link to share the post
    And I should see "1 photo"
    And I should see "3 people"
    And I should see 1 big image
    And I should see "Huey Lewis"
    And I should see "Check out who just arrived!"
    And I should see "Posted on 29/04/2010"
    And I should see 2 comments
  
  Scenario: See paginated thumbnails
    Given I am a logged in Facebook user with uid "123123"
    And I am a Chiive user
    And I have an event named "Hot Diggity!"
    And the event has 50 images
    When I go to the event page for the event
    Then I should see "50 photos"
    And I should see 48 thumbnail images
    And I should see thumbnail pagination
    When I follow "2" within "ul#post_pages"
    Then I should be on the event page for the event
    And I should see 2 thumbnail images
  
  Scenario: See paginated attendees
    Given I am a logged in Facebook user with uid "123123"
    And I am a Chiive user
    And I have an event named "Hot Diggity!"
    And the event has 15 attendees
    When I go to the event page for the event
    Then I should see 10 attendee names
    And I should see user pagination
    When I follow "2" within "ul#user_pages"
    Then I should be on the event page for the event
    And I should see 5 attendee names
  
  # Scenario: Share the event
  #   Given I am a logged in Facebook user with uid "123123"
  #   And I am a Chiive user
  #   And I have an event named "Hot Diggity!"
  #   And I am on the event page for the event
  #   When I press "Share"
  #   Then I should see a Facebook "Share" modal dialog
  #   And I should see "Post to Profile"
  #   And I should see "Hot Diggity!"
  # 
  # Scenario: View the sharer's profile
  #   Given I have an event named "Hot Diggity!"
  #   And the event was shared by Chiive user "John Smith"
  #   And the event sharer has connected his Chiive account to Facebook
  #   Then I should see "John Smith" above "Hot Diggity"
  #   When I click "John Smith"
  #   Then I should be on the Facebook profile page of "John Smith"
  # 
  # Scenario: View an attendee's profile
  #   Given I have an event named "Hot Diggity!"
  #   And the event has an attendee named "Huey Lewis"
  #   And the "Huey Lewis" has connected his Chiive account to Facebook
  #   Then I should see "Huey Lewis" below "Photos By"
  #   When I click "Huey Lewis"
  #   Then I should be on the Facebook profile page of "Huey Lewis"
  #
  # Scenario: View photo detail
  #   Given I am a logged in Facebook user with uid "123123"
  #   And I have an event named "Hot Diggity!"
  #   And I am on the event page for the event
  #   And the event has 1 photo
  #   When I click on the photo thumbnail
  #   Then I should be on the photo detail page
