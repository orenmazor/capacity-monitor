class RenameHostToAgent < ActiveRecord::Migration
  def up
    execute "ALTER TABLE hosts RENAME to agents"
  end

  def down
    execute "ALTER TABLE agents RENAME to hosts"
  end
end
