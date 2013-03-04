class FactSample < Sample
  BUCKET_SIZE = 5000
  before_save :calculate_bucket_number

  def self.find_latest_values_and_run_ids_per_bucket(start_run, end_run)
    sql = "SELECT * FROM samples WHERE type = 'FactSample' AND run_id IN 
      (SELECT MAX(run_id) as run_id FROM samples WHERE type = 'FactSample' 
       AND run_id >= #{start_run} AND run_id <= #{end_run} GROUP BY bucket_number)"

    find_by_sql(sql)
  end

  private

  def calculate_bucket_number
    self.bucket_number = value.to_f.ceil / BUCKET_SIZE
  end
end
