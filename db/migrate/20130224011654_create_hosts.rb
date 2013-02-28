class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.integer :newrelic_id
      t.string :hostname

      t.timestamps
    end
  end
end
