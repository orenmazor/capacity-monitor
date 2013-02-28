class AddCurveToMetric < ActiveRecord::Migration
  def change
    add_column :metrics, :points_cache, :text
    add_column :metrics, :trend, :text
    add_column :metrics, :bottom_confidence, :text
    add_column :metrics, :top_confidence, :text
    add_column :metrics, :ceiling, :integer
    add_column :metrics, :r_squared, :float
    add_column :metrics, :guess, :string
  end
end
