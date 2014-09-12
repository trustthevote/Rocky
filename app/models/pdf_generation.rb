class PdfGeneration < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :registrant
  
  
  def self.retrieve
    pdfgen_id = nil
    PdfGeneration.transaction do
      pdfgen  = self.where(:locked => false).lock(true).first
      if pdfgen
        pdfgen.locked = true
        pdfgen.save!
        pdfgen_id = pdfgen.id
      end
    end
    puts "Failed to get lock!" if pdfgen_id.nil?
    return pdfgen_id
  end
  
  def self.find_and_remove
    pdfgen_id = retrieve
    if pdfgen_id
      pdfgen = self.find(pdfgen_id)
      pdfgen.delete
      puts "Removed #{pdfgen.id}"
    end    
  end
  
  def self.find_and_htmlify
    pdfgen_id = retrieve
    if pdfgen_id
      pdfgen = self.find(pdfgen_id)
      r = pdfgen.registrant
      if r && r.generate_pdf_html
        r.update_attribute('pdf_ready', true)
        puts "Generated HTML for #{r.id}"
        pdfgen.delete
      else
        puts "FAILED to generate HTML for #{r.id}"
      end
    end
  end
  
  def self.find_and_generate
    pdfgen_id = retrieve
    if pdfgen_id
      pdfgen = self.find(pdfgen_id)
      r = pdfgen.registrant
      if r && r.generate_pdf(true)
        r.update_attribute('pdf_ready', true)
        puts "Generated #{r.pdf_path}"
        pdfgen.delete
      else
        puts "FAILED to generate PDF for #{r.id}"
      end
    end
  end
  
end
