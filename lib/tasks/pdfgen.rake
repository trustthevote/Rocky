namespace :pdf do
  
  desc "Generate PDFs from the queue"
  task :generate => :environment do
    loop do
      PdfGeneration.find_and_generate
      sleep(0.1)
    end
  end
  
  desc "Empty the queue"
  task :dequeue => :environment do
    loop do
      PdfGeneration.find_and_remove
      sleep(0.1)
    end
  end

  desc "Built the HTMLs from the queue"
  task :htmlify => :environment do
    loop do
      PdfGeneration.find_and_htmlify
      sleep(0.1)
    end
  end
  
end
