class PdfGeneration < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :registrant
  
  def self.find_and_generate
    pdfgen_id = nil
    PdfGeneration.transaction do
      pdfgen  = self.where(:locked => false).lock(true).first
      if pdfgen
        pdfgen.locked = true
        pdfgen.save!
        pdfgen_id = pdfgen.id
      end
    end
    
    if pdfgen_id
      pdfgen = self.find(pdfgen_id)
      r = pdfgen.registrant
      if r && r.generate_pdf
        r.update_attribute('pdf_ready', true)
        puts "Generated #{r.pdf_path}"
        pdfgen.delete
      end
    end
  end
  
end
