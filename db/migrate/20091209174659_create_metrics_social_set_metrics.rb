class CreateMetricsSocialSetMetrics < ActiveRecord::Migration
  def self.up
    create_table :metrics_social_set_metrics do |t|

      t.datetime :time_at
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      
      #t.decimal :weight, :precision => 15, :scale => 10 
      t.decimal :wx, :precision => 15, :scale => 10 
      t.decimal :wy, :precision => 15, :scale => 10 
      t.decimal :wt, :precision => 15, :scale => 10 
      
      #t.integer :set_id, :null => false, :options => "CONSTRAIN fk_metrics_set_metrics_set REFERENCES group(id)"
      
      t.timestamps
    end
    add_column :social_sets, :metrics_id, :integer

  end

  def self.down
    drop_table :metrics_social_set_metrics
    remove_column :social_sets, :metrics_id
  end
end
