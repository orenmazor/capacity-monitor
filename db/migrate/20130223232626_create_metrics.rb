class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :host
      t.string :type
      t.string :reference
      t.integer :maximum
      t.timestamps
    end
  end
end
