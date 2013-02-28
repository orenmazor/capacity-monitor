class AddTypeToSample < ActiveRecord::Migration
  def change
    change_table :samples do |t|
      t.string :type
    end
  end
end
