user1 = User.create(
  :facebook_uid          => 1285070844,
  :first_name            => 'Anton',
  :last_name             => 'Rogov',
  :name                  => 'Anton Rogov',
  :login                 => 'user1',
  :email                 => 'anton@flatsourcing.com',
  :password              => '123456',
  :password_confirmation => '123456'
)

user2 = User.create(
  :first_name            => 'John',
  :last_name             => 'Smith',
  :name                  => 'John Smith',
  :login                 => 'user2',
  :email                 => 'anton+1@flatsourcing.com',
  :password              => '123456',
  :password_confirmation => '123456'
)

user3 = User.create(
  :first_name            => 'Huey',
  :last_name             => 'Lewis',
  :name                  => 'Huey Lewis',
  :login                 => 'user3',
  :email                 => 'anton+2@flatsourcing.com',
  :password              => '123456',
  :password_confirmation => '123456'
)


event = SocialSet.new(
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now
)
set1 = event.personal_sets.build(
  :user      => user1,
  :title     => 'Hot Diggity!',
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now
)
post1 = set1.posts.build(
  :user      => user1,
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now,
  :title     => 'Photo 1',
  :photo     => File.new("#{RAILS_ROOT}/public/images/test.jpg")
)
event.save!

set2 = event.personal_sets.create(
  :user      => user2,
  :title     => 'Event 2',
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now
)
post2 = set1.posts.create(
  :user      => user2,
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now,
  :title     => 'Photo 2',
  :photo     => File.new("#{RAILS_ROOT}/public/images/test.jpg")
)
post3 = set2.posts.create(
  :user      => user2,
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now,
  :title     => 'Photo 3',
  :photo     => File.new("#{RAILS_ROOT}/public/images/test.jpg")
)

set3 = event.personal_sets.create(
  :user      => user3,
  :title     => 'Event 3',
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now
)
post4 = set3.posts.create(
  :user      => user3,
  :latitude  => 1,
  :longitude => 100,
  :time_at   => Time.now,
  :title     => 'Photo 4',
  :photo     => File.new("#{RAILS_ROOT}/public/images/test.jpg")
)


50.times do |i|
  set1.posts.create(
    :user      => user1,
    :latitude  => 1,
    :longitude => 100,
    :time_at   => Time.now,
    :title     => "Photo #{i + 5}",
    :photo     => File.new("#{RAILS_ROOT}/public/images/test.jpg")
  )
end

20.times do |i|
  user = User.create(
    :first_name            => 'Test',
    :last_name             => "User #{i + 1}",
    :name                  => "Test User #{i + 1}",
    :login                 => "user#{i + 4}",
    :email                 => "anton+#{i + 4}@flatsourcing.com",
    :password              => '123456',
    :password_confirmation => '123456'
  )
  set = event.personal_sets.create(
    :user      => user,
    :title     => "Event #{i + 4}",
    :latitude  => 1,
    :longitude => 100,
    :time_at   => Time.now
  )
  post = set.posts.create(
    :user      => user,
    :latitude  => 1,
    :longitude => 100,
    :time_at   => Time.now,
    :title     => "Test Photo #{i + 1}",
    :photo     => File.new("#{RAILS_ROOT}/public/images/test.jpg")
  )
end
