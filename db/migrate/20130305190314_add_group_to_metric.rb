class AddGroupToMetric < ActiveRecord::Migration
  def change
    change_table :metrics do |t|
      t.string :group
    end
  end
end
