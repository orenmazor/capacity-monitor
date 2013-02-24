class AddSourceToMetric < ActiveRecord::Migration
  def change
    add_column :metrics, :source, :string
  end
end
