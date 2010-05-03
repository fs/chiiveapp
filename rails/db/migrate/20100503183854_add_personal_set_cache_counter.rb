class AddPersonalSetCacheCounter < ActiveRecord::Migration
  def self.up
    add_column :social_sets, :personal_sets_count, :integer, :default => 0
    
    sql = "UPDATE social_sets SET social_sets.personal_sets_count = (SELECT COUNT(*) FROM personal_sets WHERE social_set_id = social_sets.id)"
    SocialSet.connection.execute(sql)
  end

  def self.down
    remove_column :social_sets, :personal_sets_count
  end
end
