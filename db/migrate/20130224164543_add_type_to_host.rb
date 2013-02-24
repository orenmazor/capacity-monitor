class AddTypeToHost < ActiveRecord::Migration
  def change
    change_table "hosts" do |t|
      t.string "role"
    end
    change_table "metrics" do |t|
      t.integer "host_id"
      t.remove "host"
    end
  end
end
