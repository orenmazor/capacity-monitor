class AddRunIdToSample < ActiveRecord::Migration
  def change
    add_column :samples, :run_id, :integer
  end
end
