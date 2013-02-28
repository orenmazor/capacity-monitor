class AddBucketNumberToSample < ActiveRecord::Migration
  def change
    add_column :samples, :bucket_number, :int
  end
end
