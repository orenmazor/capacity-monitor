class AddFetchedAtToSample < ActiveRecord::Migration
  def change
    add_column :samples, :fetched_at, :datetime
  end
end
