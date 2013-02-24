class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.integer "metric_id"
      t.decimal "value", :precision => 6, :scale => 4
      t.timestamps
    end
  end
end
