Factory.define :user do |f|
  f.sequence(:first_name) { |n| "Frank#{n}" }
  f.sequence(:last_name) { |n| "Furter#{n}" }
  f.sequence(:login) { |n| "frank#{n}" }
  f.sequence(:email) { |n| "frank#{n}@furter.com" }
  f.password "fo0bar"
  f.password_confirmation { |u| u.password }
end

Factory.define :personal_set do |f|
  f.sequence(:title) { |n| "Personal Set #{n}" }
  f.latitude 1
  f.longitude 100
  f.time_at Time.now
  f.association :user
end

Factory.define :social_set do |f|
  f.personal_sets {|personal_sets| [personal_sets.association(:personal_set)]}
end

Factory.define :post do |f|
  f.sequence(:title) { |n| "Post #{n}" }
  #f.text "Frank's text description here here"
  f.latitude 33.3
  f.longitude 44.4
  f.time_at Time.now
  f.photo_content_type "image/jpeg"
  f.photo_file_size 123456
  f.photo_file_name "foto.jpg"
  f.photo_updated_at Time.now
  f.association :user
  f.association :personal_set
end

Factory.define :comment do |f|
  f.sequence(:title) { |n| "Title#{n}" }
  f.sequence(:body) { |n| "Body #{n}" }
  f.association :user
end

