Factory(:user, :facebook_uid => 1234)

at_exit do
  User.destroy_all
end

Given /^I have an event named "([^\"]*)"$/ do |title|
  @event = Factory(:social_set)
  @event.title = title
  @event.save
end

Given /^the event was created by Chiive user "([^\"]*)"$/ do |name|
  @event.default_user.name = name
  @event.default_user.save
end

Given /^the event has (\d+) images?$/ do |count|
  count.to_i.times do |i|
    Factory(:post, :user => @event.default_user, :personal_set => @event.default_personal_set)
  end
end

Given /^the event has post with title "([^\"]*)" posted on "([^\"]*)" by "([^\"]*)"$/ do |title, date, name|
  user = Factory(:user, :name => name)
  @post = Factory(:post,
    :title        => title,
    :time_at      => Time.parse(date) + 12.hours,
    :user         => user,
    :personal_set => @event.default_personal_set
  )
end

Given /^the event has (\d+) attendees?$/ do |count|
  (count.to_i - 1).times do |i|
    Factory(:personal_set, :social_set => @event)
  end
end

Given /^the event has (\d+) comments?$/ do |count|
  count.to_i.times do |i|
    Factory(:comment, :user => @event.default_user, :commentable => @event)
  end
end

Then /^I should see the avatar image of "([^\"]*)"$/ do |name|
  assert_have_selector 'div#info img'
  # user = User.find_by_name(name)
  # assert_have_selector 'img', :src => "http://example.com#{user.avatar_image.url(:small)}"
  # assert_have_selector %Q[fb:profile-pic[uid="#{user.facebook_uid}"]]
end

Then /^I should see a "([^\"]*)" link to post a comment$/ do |title|
  assert_have_selector 'input', :type => 'submit', :value => title
end

Then /^I should see a "([^\"]*)" link to share the event$/ do |arg1|
  assert_have_selector 'share-button', :class => 'url', :href => "http://apps.facebook.com/events/#{@event.id}"
end

Then /^I should see a "([^\"]*)" link to share the post$/ do |arg1|
  assert_have_selector 'share-button', :class => 'url', :href => "http://apps.facebook.com/events/#{@event.id}/posts/#{@post.id}"
end

Then /^I should see (\d+) thumbnail images?$/ do |count|
  assert_have_selector 'div#photos_container div.clearfix a', :count => count
end

Then /^I should see (\d+) attendee names?$/ do |count|
  assert_have_selector 'div#photosby div.entry', :count => count
end

Then /^I should see (\d+) comments?$/ do |count|
  assert_have_selector 'div#comments div.comment', :count => count
end

Then /^I should not see thumbnail pagination$/ do
  assert_have_no_selector 'ul', :class => 'pagination', :id => 'post_pages'
end

Then /^I should not see user pagination$/ do
  assert_have_no_selector 'ul', :class => 'pagination', :id => 'users_pages'
end

Then /^I should see thumbnail pagination$/ do
  assert_have_selector 'ul', :class => 'pagination', :id => 'post_pages'
end

Then /^I should see user pagination$/ do
  assert_have_selector 'ul', :class => 'pagination', :id => 'user_pages'
end

Given /^the post has (\d+) comments?$/ do |count|
  count.to_i.times do |i|
    Factory(:comment, :user => @event.default_user, :commentable => @post)
  end
end

Then /^I should see 1 big image$/ do
  assert_have_selector 'div#photo img'
end



Given /^I am a Chiive user "([^\"]*)", and avatar image "([^\"]*)"$/ do |name, avatar_image|
  @user = Factory(:user, :name => name)
end

Given /^I have connected my Facebook Account with uid "([^\"]*)" to my Chiive account$/ do |uid|
  @user.facebook_uid = 1234#uid
  @user.save
end

Then /^a comment should exist with body "([^\"]*)"$/ do |body|
  # pending # express the regexp above with the code you wish you had
end

Then /^I should see facebook name for "([^\"]*)"$/ do |uid|
  assert_have_selector 'name', :uid => '1234'#uid
end

Then /^I should see facebook avatar for "([^\"]*)"$/ do |uid|
  assert_have_selector 'profile-pic', :uid => '1234'#uid
end

Given /^I am a logged in Facebook user with uid "([^\"]*)"$/ do |arg1|
end

Given /^I am a Chiive user$/ do
end
