class FactSample < Sample
  BUCKET_SIZE = 5000
  before_save :calculate_bucket_number

  def self.find_latest_values_and_run_ids_per_bucket
    select('value, MAX(run_id) AS run_id').group([:bucket_number, :value])
  end

  private

  def calculate_bucket_number
    self.bucket_number = value.to_f.ceil / BUCKET_SIZE
  end
end
