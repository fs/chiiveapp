class Photo < ActiveRecord::Base
  belongs_to :user
  
  def next_photo
    @next_photo ||= Photo.first(:conditions => ['id > ?', id], :order => 'id')
  end
  
  def previous_photo
    @previous_photo ||= Photo.first(:conditions => ['id < ?', id], :order => 'id DESC')
  end
end
