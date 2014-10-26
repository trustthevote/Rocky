
module SpecHelperMethods

  def fixture_files_path
    Rails.root.join("spec/fixtures/files")
  end
  
  def fixture_file_contents(path)
    c = ''
    File.open(fixture_files_path.join(path)) do |f|
      c = f.read
    end
    c
  end

  def fixture_files_file_upload(path, mime_type = nil, binary = false)
    Rack::Test::UploadedFile.new("#{fixture_files_path}#{path}", mime_type, binary)    
  end
  
  def silence_output
    old_stdout = $stdout
    $stdout = StringIO.new('')
    yield
  ensure
    $stdout = old_stdout
  end
  

end