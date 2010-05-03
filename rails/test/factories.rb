Factory.define :user do |f|
  f.sequence(:name) { |n| "Frank #{n}" }
  f.sequence(:login) { |m| "frank#{m}" }
  f.sequence(:email) { |o| "frank#{o}@example.com" }
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
  # f.association :personal_sets
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

