namespace :pdf do
  
  desc "Remove pdf directories that are past the expiration date"
  task :generate => :environment do
    loop do
      PdfGeneration.find_and_generate
      sleep(0.1)
    end
  end
end
