class AddCurveToMetric < ActiveRecord::Migration
  def change
    add_column :metrics, :slope, :float
    add_column :metrics, :offset, :float
  end
end
