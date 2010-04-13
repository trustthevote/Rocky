#!/usr/bin/env ruby
require 'time'
require 'fileutils'
class BucketRemover
  def pdf_root
    File.expand_path(File.join(File.dirname(__FILE__), "../pdf"))
  end

  def expired_buckets
    Dir["#{pdf_root}/*"].select { |dir| File.directory?(dir) && File.mtime(dir) < expired_time }
  end

  def expiration_period
    if ENV['RAILS_ENV'] == "staging"
      360       # 6.minutes
    else
      1_209_600 # 14.days
    end
  end

  def expired_time
    Time.at(Time.parse(`date`).to_i - expiration_period)
  end

  def remove_buckets!
    expired_buckets.each { |bucket| FileUtils.rm_rf(bucket) }
  end
end

BucketRemover.new.remove_buckets! if $0 == __FILE__
