Given /^a social_set exists with title "([^\"]*)"$/ do |title|
	social_set = Factory.build(:social_set)
	social_set.default_personal_set.title = title
	social_set.save
end
