class RenameMetricsHostIdToAgentId < ActiveRecord::Migration
  def up
    rename_column :metrics, :host_id, :agent_id
  end

  def down
  end
end
