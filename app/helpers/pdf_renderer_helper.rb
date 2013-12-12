module PdfRendererHelper
  
  def non_english?
    @registrant.locale.to_s != 'en'
  end
  
  def form_prompt(key)
    other_eng = []
    other_eng << I18n.t(key, :locale=>'en') if non_english?  
    other_eng << I18n.t(key)
    val = other_eng.uniq.join("/")
    val = "<span class='smaller_prompt'>#{val}</span>" if non_english?
    val 
  end
  
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