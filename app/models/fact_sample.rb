class FactSample < Sample
  BUCKET_SIZE = 5000

  before_save :calculate_bucket_number

  private

  def calculate_bucket_number
    write_attribute(:bucket_number, value.to_f.ceil / BUCKET_SIZE)
  end
end
