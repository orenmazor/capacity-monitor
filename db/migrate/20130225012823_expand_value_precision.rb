class ExpandValuePrecision < ActiveRecord::Migration
  def up
    change_column "samples", "value", "decimal(14, 4)"
  end

  def down
  end
end
