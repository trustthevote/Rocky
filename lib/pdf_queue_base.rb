module PdfQueueBase
  
  def sleep_timeout
    3
  end
  
  def retrieve
    pdfgen_id = nil
    self.transaction do
      pdfgen  = self.where(:locked => false).lock(true).first
      if pdfgen
        pdfgen.locked = true
        pdfgen.save!
        pdfgen_id = pdfgen.id
      end
    end
    if pdfgen_id.nil?
      # Try an old locked one
      self.transaction do
        pdfgen  = self.where(:locked => true).where("updated_at < ?", 10.minutes.ago).lock(true).first
        if pdfgen
          pdfgen.locked = true
          pdfgen.updated_at = Time.now
          pdfgen.save!
          pdfgen_id = pdfgen.id
        end
      end
      if pdfgen_id.nil? 
        if self.count != 0
          Rails.logger.warn "#{Time.now} Couldn't get lock on any #{self.class.name}" 
        end
        sleep(sleep_timeout)
      end
    end
    return pdfgen_id
  end
  
  # def self.find_and_remove
  #   pdfgen_id = retrieve
  #   if pdfgen_id
  #     pdfgen = self.find(pdfgen_id)
  #     pdfgen.delete
  #     puts "Removed #{pdfgen.id}"
  #   end
  # end
  
  # def self.find_and_htmlify
  #   pdfgen_id = retrieve
  #   if pdfgen_id
  #     pdfgen = self.find(pdfgen_id)
  #     r = pdfgen.registrant
  #     if r && r.generate_pdf_html
  #       r.finish_pdf
  #       puts "Generated HTML for #{r.id}"
  #       pdfgen.delete
  #     else
  #       puts "FAILED to generate HTML for #{r.id}"
  #     end
  #   end
  # end
  
  def find_and_generate
    pdfgen_id = retrieve
    if pdfgen_id
      pdfgen = self.find(pdfgen_id, :include => :registrant)
      r = pdfgen.registrant
      if r && r.generate_pdf #(true)
        r.finalize_pdf
        # puts "Generated #{r.pdf_path}"
        pdfgen.delete
      else
        Rails.logger.error "FAILED to generate #{self.class.name} id #{pdfgen_id}"
      end
    end
  rescue Exception => e
    Rails.logger.error "#{Time.now} Error finding and generating PDF:\n#{e.message}\n#{e.backtrace}"
    sleep(15)
    #raise e
  end
  
end