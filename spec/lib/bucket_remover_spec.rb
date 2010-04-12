require File.dirname(__FILE__) + '/../spec_helper'

describe BucketRemover do
  before(:each) do
    @folder_name = Rails.root.join("tmp/pdf_#{$$}_#{Time.now.to_i}_#{Time.now.usec.to_i}")
    (21..30).each do |i|
      file_name = "#{@folder_name}/d.#{i}"
      create_dir_in_past(file_name, ((i*12).hours + 5.minutes))
    end

    @remover = BucketRemover.new
    stub(@remover).pdf_root { @folder_name }
  end

  def create_dir_in_past(path, ago)
    mtime = (Time.parse(`date`) - ago).strftime("%m%d%H%M")
    FileUtils.mkdir_p(path)
    `touch -t #{mtime} #{path}`
  end

  it "has 3 dirs more than 14.0 days old" do
    expired_buckets = @remover.expired_buckets
    assert_equal 3, expired_buckets.length
  end

  it "should delete expired directories" do
    assert_difference %Q(Dir["#{@folder_name}/*"].length), -3 do
      @remover.remove_buckets!
    end
  end
end
