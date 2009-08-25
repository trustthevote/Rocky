module Lolrus
  SECONDS_PER_BUCKET = 316
  NUM_BUCKETS = 4096

  def bucket_code(timestamp)
    ((timestamp.to_i/SECONDS_PER_BUCKET) % NUM_BUCKETS).to_s(16)
  end
end
