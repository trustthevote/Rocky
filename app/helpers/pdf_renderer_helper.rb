module PdfRendererHelper
  
  def checked?(key, attr_name)
    @registrant.send("#{attr_name}_key") == key
  end

  def checkbox(key, attr_name)
    if checked?(key, attr_name)
      wicked_pdf_image_tag("pdf/titleCheckboxChecked.png")
    else
      wicked_pdf_image_tag("pdf/titleCheckboxUnchecked.png")
    end
  end


end