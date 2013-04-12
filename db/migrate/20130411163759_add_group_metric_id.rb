class AddGroupMetricId < ActiveRecord::Migration
  def up
    add_column :metrics, :group_metric_id, "INT(11)"
    add_column :group_name, "VARCHAR2(50)"
    remove_column :group
  end

  def down
  end
end
