namespace :pdf do
  
  desc "Remove pdf directories that are past the expiration date"
  task :generate => :environment do
    loop do
      PdfGenerator.find_and_generate
    end
  end
end
