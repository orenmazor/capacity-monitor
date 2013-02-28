class FactSample < Sample
  BUCKET_SIZE = 5000

  def calculate_bucket_number
    value.to_f.floor / BUCKET_SIZE
  end
end
