class AddSampleThruzero < ActiveRecord::Migration
  def change
    add_column :samples, :thruzero, :int
  end
end
