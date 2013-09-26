
module SpecHelperMethods

  def fixture_files_path
    Rails.root.join("spec/fixtures/files")
  end

  def fixture_files_file_upload(path, mime_type = nil, binary = false)
    Rack::Test::UploadedFile.new("#{fixture_files_path}#{path}", mime_type, binary)    
  end

end