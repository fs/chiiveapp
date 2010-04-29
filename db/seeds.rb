[
  {:name => 'John Smith', :facebook_uid => 1285070844},
  {:name => 'Pashû Pathina Dewailly Christensen'},
  {:name => 'Jonathan Gagnon-Bagheri', :facebook_uid => 1828245772},
  {:name => 'Monika Blasthaus Bernstein', :facebook_uid => 100000066328092},
  {:name => 'Oleg Kurnosov', :facebook_uid => 1075931533},
  {:name => 'Jonathan Gagnon-Bagheri', :facebook_uid => 1828245772},
  {:facebook_uid => 100000091858439},
  {:name => 'Chris Schultz', :facebook_uid => 690997250},
  {:name => 'John Smith', :facebook_uid => 1285070844},
  {:name => 'Oleg Kurnosov', :facebook_uid => 1075931533}
].each do |user_attributes|
  u = User.create(user_attributes)
  photo_count = 10 + rand(5)
  photo_count.times do |i|
    u.photos.create(
      :thumb_url => "/images/copy/thumb#{rand(7) + 1}_80x80.jpg",
      :image_url => "/images/copy/photo#{rand(2) + 1}.jpg"
    )
  end
end
