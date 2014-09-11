class PdfGenerator
  
  def self.find_and_generate
    Registrant.transaction do
      r = Registrant.where(:pdf_ready=>nil, :status=>'complete').lock(true).first
      if r.generate_pdf
        r.update_attribute('pdf_ready', true)
      end      
    end 
  end
  
end