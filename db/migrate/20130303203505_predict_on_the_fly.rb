class PredictOnTheFly < ActiveRecord::Migration
  def up
    remove_column :metrics, :slope
    remove_column :metrics, :offset
    remove_column :metrics, :prediction
    remove_column :metrics, :best_fit
    remove_column :metrics, :points
    change_table :metrics do |t|
      t.boolean :relevant
    end
  end

  def down
  end
end
