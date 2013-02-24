class AddFieldToMetric < ActiveRecord::Migration
  def change
    change_table "metrics" do |t|
      t.string "field"
    end
  end
end
