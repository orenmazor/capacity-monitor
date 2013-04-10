class AddSummaryTable < ActiveRecord::Migration
  def up
    create_table :summaries do |t|
      t.date :date
      t.text :summary
    end
  end

  def down
    drop_table :summaries
  end
end
