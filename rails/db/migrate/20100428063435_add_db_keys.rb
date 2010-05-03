class AddDbKeys < ActiveRecord::Migration
  def self.up
    add_index :posts, :user_id
    add_index :posts, :time_at
    add_index :posts, :personal_set_id
    add_index :personal_sets, :user_id
    add_index :personal_sets, :social_set_id
    add_index :personal_sets, :order_social_set
    add_index :metrics_set_metrics, :time_at
    add_index :metrics_set_metrics, :latitude
    add_index :metrics_set_metrics, :longitude
    add_index :metrics_social_set_metrics, :time_at
    add_index :metrics_social_set_metrics, :latitude
    add_index :metrics_social_set_metrics, :longitude
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
    ###
  end

  def self.down
    remove_index :posts, :user_id
    remove_index :posts, :time_at
    remove_index :posts, :personal_set_id
    remove_index :personal_sets, :user_id
    remove_index :personal_sets, :social_set_id
    remove_index :personal_sets, :order_social_set
    remove_index :metrics_set_metrics, :time_at
    remove_index :metrics_set_metrics, :latitude
    remove_index :metrics_set_metrics, :longitude
    remove_index :metrics_social_set_metrics, :time_at
    remove_index :metrics_social_set_metrics, :latitude
    remove_index :metrics_social_set_metrics, :longitude
    remove_index :comments, :commentable_id
    remove_index :comments, :commentable_type
    ###
  end
end
