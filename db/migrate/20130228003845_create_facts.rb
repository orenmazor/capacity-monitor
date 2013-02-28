class CreateFacts < ActiveRecord::Migration
  def change
    rename_column :samples, :metric_id, :owner_id
    change_table :samples do |t|
      t.string :owner_type
    end

    create_table :facts do |t|
      t.string :type
      t.string :resource
      t.integer :bucket_size

      t.timestamps
    end
  end
end
