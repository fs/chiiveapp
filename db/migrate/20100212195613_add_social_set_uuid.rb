class AddSocialSetUuid < ActiveRecord::Migration
  def self.up
    add_column :social_sets, :uuid, :string
    add_index :social_sets, :uuid
    
    @social_sets = SocialSet.find(:all)
    @social_sets.each do |social_set|
      SocialSet.connection.execute("UPDATE social_sets SET uuid=\"#{UUIDTools::UUID.timestamp_create().to_s.upcase}\" WHERE id=#{social_set.id}")
    end
  end

  def self.down
    remove_index :social_sets, :uuid
    remove_column :social_sets, :uuid
  end
end
