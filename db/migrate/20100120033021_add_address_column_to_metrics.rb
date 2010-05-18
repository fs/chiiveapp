class AddAddressColumnToMetrics < ActiveRecord::Migration
  def self.up
    add_column :metrics_set_metrics, :address_id, :integer
    add_column :metrics_social_set_metrics, :address_id, :integer
  end

  def self.down
    remove_column :metrics_set_metrics, :addresss_id
    remove_column :metrics_social_set_metrics, :addresss_id
  end
end

