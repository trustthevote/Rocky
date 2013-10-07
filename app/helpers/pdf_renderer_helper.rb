module PdfRendererHelper
  def checkbox(key, attr_name)
    if @registrant.send("#{attr_name}_key") == key
      wicked_pdf_image_tag("pdf/titleCheckboxChecked.png")
    else
      wicked_pdf_image_tag("pdf/titleCheckboxUnchecked.png")
    end
  end


end