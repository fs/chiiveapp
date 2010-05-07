Given (/^(the social_set) has title "([^\"]*)"$/) do |a, the_title|
	social_set = model!(a)
	 # for some reason you have to access the object itself, rather than assigning via the parent
	personal_set = social_set.default_personal_set
	personal_set.title = the_title
  personal_set.save
end

Given (/^(the social_set) was created by user "([^\"]*)"$/) do |a, user_name|
  social_set = model!(a)
   # for some reason you have to access the object itself, rather than assigning via the parent
  user = social_set.default_user
  user.first_name = user_name.split(" ").first
  user.last_name = user_name.split(" ").last
  user.save
end

Given (/^(the social_set) has ([0-9]+) attendees$/) do |a, count|
  social_set = model!(a)
  count = count.to_i
  max = 20
  while social_set.personal_sets.size < count && --max > 0
    social_set.personal_sets << Factory(:personal_set)
  end
end

Given (/^(the social_set) has ([0-9]+) posts$/) do |a, count|
  social_set = model!(a)
  personal_set = social_set.default_personal_set
  count = count.to_i
  max = 20
  while personal_set.posts.size < count && --max > 0
    personal_set.posts << Factory(:post, :personal_set => personal_set)
  end
end


Given (/^(the social_set) has ([0-9]+) comments$/) do |a, count|
  social_set = model!(a)
  count = count.to_i
  max = 20
  while social_set.comments.size < count && --max > 0
    social_set.comments << Factory(:comment)
  end
end
