class RemoveSetMetrics < ActiveRecord::Migration
  def self.up
    add_column :social_sets, :time_at, :datetime
    add_column :social_sets, :latitude,:decimal, :precision => 15, :scale => 10
    add_column :social_sets, :longitude, :decimal, :precision => 15, :scale => 10
    
    add_column :personal_sets, :time_at, :datetime
    add_column :personal_sets, :latitude,:decimal, :precision => 15, :scale => 10
    add_column :personal_sets, :longitude, :decimal, :precision => 15, :scale => 10
    
    # Move the metrics values onto the social sets
    sql = "UPDATE social_sets s, metrics_social_set_metrics m "
    sql += "SET s.time_at = m.time_at, s.latitude = m.latitude, s.longitude = m.longitude "
    sql += "WHERE s.metrics_id = m.id "
    SocialSet.connection.execute(sql)
    
    # Move the metrics values onto the personal sets
    sql = "UPDATE personal_sets p, metrics_set_metrics m "
    sql += "SET p.time_at = m.time_at, p.latitude = m.latitude, p.longitude = m.longitude "
    sql += "WHERE p.metrics_id = m.id "
    PersonalSet.connection.execute(sql)
    
    # Inherit any missing personal set data from the social sets
    sql = "UPDATE personal_sets p, social_sets s "
    sql += "SET p.time_at = s.time_at, p.latitude = s.latitude, p.longitude = s.longitude "
    sql += "WHERE p.social_set_id = s.id AND (p.time_at IS NULL OR p.latitude IS NULL OR p.longitude IS NULL) "
    PersonalSet.connection.execute(sql)
    
    remove_column :social_sets, :metrics_id
    remove_column :personal_sets, :metrics_id
    
    drop_table :metrics_social_set_metrics
    drop_table :metrics_set_metrics
  end

  def self.down
    create_table "metrics_set_metrics", :force => true do |t|
      t.datetime "time_at"
      t.decimal  "latitude",   :precision => 15, :scale => 10
      t.decimal  "longitude",  :precision => 15, :scale => 10
      t.decimal  "wx",         :precision => 15, :scale => 10
      t.decimal  "wy",         :precision => 15, :scale => 10
      t.decimal  "wt",         :precision => 15, :scale => 10
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "address_id"
    end

    add_index "metrics_set_metrics", ["latitude"], :name => "index_metrics_set_metrics_on_latitude"
    add_index "metrics_set_metrics", ["longitude"], :name => "index_metrics_set_metrics_on_longitude"
    add_index "metrics_set_metrics", ["time_at"], :name => "index_metrics_set_metrics_on_time_at"

    create_table "metrics_social_set_metrics", :force => true do |t|
      t.datetime "time_at"
      t.decimal  "latitude",   :precision => 15, :scale => 10
      t.decimal  "longitude",  :precision => 15, :scale => 10
      t.decimal  "wx",         :precision => 15, :scale => 10
      t.decimal  "wy",         :precision => 15, :scale => 10
      t.decimal  "wt",         :precision => 15, :scale => 10
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "address_id"
    end

    add_index "metrics_social_set_metrics", ["latitude"], :name => "index_metrics_social_set_metrics_on_latitude"
    add_index "metrics_social_set_metrics", ["longitude"], :name => "index_metrics_social_set_metrics_on_longitude"
    add_index "metrics_social_set_metrics", ["time_at"], :name => "index_metrics_social_set_metrics_on_time_at"
    
    add_column :social_sets, :metrics_id
    add_column :personal_sets, :metrics_id
    
    remove_column :social_sets, :time_at
    remove_column :social_sets, :latitude
    remove_column :social_sets, :longitude
    
    remove_column :personal_sets, :time_at
    remove_column :personal_sets, :latitude
    remove_column :personal_sets, :longitude
    
  end
end
