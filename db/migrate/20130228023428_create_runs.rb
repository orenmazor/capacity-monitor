class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.datetime :begin
      t.datetime :end
      t.text :failures

      t.timestamps
    end
  end
end
