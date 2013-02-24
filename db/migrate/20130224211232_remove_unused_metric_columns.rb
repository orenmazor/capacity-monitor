class RemoveUnusedMetricColumns < ActiveRecord::Migration
  def up
    change_table "metrics" do |t|
      t.remove :source
      t.remove :reference
    end
  end

  def down
  end
end
