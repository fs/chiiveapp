class Comment < ActiveRecord::Base
  acts_as_uuidobject
  
  validates_presence_of :title
  
  # Tell the model that we're creating a polymorphic association through
  # our commentable_id and commentable_type columns
  belongs_to :commentable, :polymorphic => true
  
  belongs_to :user
  
  def pretty_title
    self.title.blank? ? 'Untitled' : self.title
  end
  
end
