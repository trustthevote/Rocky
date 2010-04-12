class BucketRemover
  include Lolrus

  SECONDS_IN_14_DAYS = 1_209_600

  def pdf_root
    Rails.root.join("pdf")
  end

  def expired_buckets
    Dir["#{pdf_root}/*"].select { |dir| File.directory?(dir) && File.mtime(dir) < expired_time }
  end

  def expired_time
    Time.at(Time.parse(`date`).to_i - PDF_EXPIRATION_AGE)
  end

  def remove_buckets!
    expired_buckets.each { |bucket| FileUtils.rm_rf(bucket) }
  end
end
