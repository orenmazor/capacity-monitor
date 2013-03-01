class AddPredictionToMetric < ActiveRecord::Migration
  def change
    change_table :metrics do |t|
      t.float :prediction
      t.text :best_fit
    end
  end
end
