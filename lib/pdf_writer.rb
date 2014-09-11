class PdfWriter
  @queue = :pdf_writers
  
  include ActiveModel::AttributeMethods
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  include Lolrus

  attr_accessor :id, :uid, :locale,
        :email_address,
        :us_citizen,  
        :will_be_18_by_election,
        :home_zip_code,
        :name_title,      
        :name_title_key,        
        :first_name,         
        :middle_name,        
        :last_name,   
        :name_suffix,    
        :name_suffix_key,        
        :home_address,       
        :home_unit,        
        :home_city,
        :home_state_id,       
        :mailing_address,    
        :mailing_unit,      
        :mailing_city,       
        :mailing_state_id,
        :mailing_zip_code,   
        :phone,       
        :party,   
        :state_id_number,
        :prev_name_title,
        :prev_name_title_key,    
        :prev_first_name,    
        :prev_middle_name,   
        :prev_last_name, 
        :prev_name_suffix,  
        :prev_name_suffix_key,
        :prev_address,   
        :prev_unit,       
        :prev_city,          
        :prev_state_id,
        :prev_zip_code
        
  attr_accessor :partner_absolute_pdf_logo_path,
    :registration_instructions_url,
    :home_state_pdf_instructions,
    :state_registrar_address,
    :registration_deadline,
    :english_party_name,
    :pdf_english_race,
    :pdf_date_of_birth,
    :pdf_barcode,
    :created_at
    


  validates_presence_of :id, :uid, :home_state_id, :pdf_barcode, :locale, :registration_instructions_url, :state_registrar_address, :registration_deadline, :pdf_date_of_birth, :created_at

  def us_citizen?
    self.us_citizen == true
  end
  
  def will_be_18_by_election?
    self.will_be_18_by_election == true
  end
  
  
  def yes_no(attribute)
    attribute ? "Yes" : "No"
  end
  
  def method_missing(sym, *args)
    if sym.to_s =~ /^yes_no_(.+)$/
      attribute = $1
      return self.send(:yes_no, (self.send(attribute)))
    else
      super
    end
  end
  
  def pdf_date_of_birth_month
    pdf_date_of_birth.split('/')[0]
  end
  def pdf_date_of_birth_day
    pdf_date_of_birth.split('/')[1]
  end
  def pdf_date_of_birth_year
    pdf_date_of_birth.split('/')[2]
  end

  def assign_attributes(values, options = {})
    sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
      send("#{k}=", v)
    end
  end
  
  def registrant_to_html_string
    return false if self.locale.nil? || self.home_state_id.nil?
    prev_locale = I18n.locale
    
    
    I18n.locale = self.locale
    renderer = PdfRenderer.new(self)
    
    html_string = renderer.render_to_string(
      'registrants/registrant_pdf', 
      :layout => 'layouts/nvra',
      :encoding => 'utf8',
      :locale=>self.locale
    )
    I18n.locale = prev_locale
    
    return html_string    
  end
  
  def generate_html(force_write = false)
    html_string = registrant_to_html_string
    return false if !html_string
      
    path = html_file_path
    if !File.exists?(path) || force_write
      FileUtils.mkdir_p(html_file_dir)
      File.open(path, "w") do |f|
        f << html_string.force_encoding('UTF-8')
      end
    end
  end
  
  def generate_pdf(force_write = false)
    html_string = registrant_to_html_string
    return false if !html_string

    
    PdfWriter.write_pdf_from_html_string(html_string, pdf_file_path, self.locale, pdf_file_dir, force_write)
    
    return pdf_exists?
    
  end
  #handle_asynchronously :generate_pdf, :priority=>0, :queue=>'pdfgen'
  
  def self.write_pdf_from_html_string(html_string, path, locale, pdf_file_dir, force_write = false)
    PdfWriter.write_pdf_from_html(html_string, path, locale, pdf_file_dir, force_write)
  end
  
  def pdf_exists?
    File.exists?(pdf_file_path)
  end
  
  
  
  def to_param
    self.uid
  end
  
  def html_path(pdfpre = nil, file=false)
    pdf_path(pdfpre, file).gsub(/\.pdf$/,'.html')
  end
  def pdf_path(pdfpre = nil, file=false)
    "/#{file ? pdf_file_dir(pdfpre) : pdf_dir(pdfpre)}/#{to_param}.pdf"
  end
  
  def html_file_dir(pdfpre = nil)
    pdf_file_dir(pdfpre)
  end
  def pdf_file_dir(pdfpre = nil)
    pdf_dir(pdfpre, false)
  end
  
  
  
  def pdf_dir(pdfpre = nil, url_format=true)
    if pdfpre
      "#{pdfpre}/#{bucket_code}"
    else
      if File.exists?(pdf_file_path("pdf"))
        "pdf/#{bucket_code}"
      else
        "#{url_format ? '' : "public/"}pdfs/#{bucket_code}"
      end
    end
  end
  
  def html_file_path(pdfpre = nil)
    dir = File.join(Rails.root, html_file_dir(pdfpre))
    File.join(Rails.root, html_path(pdfpre, true))
  end
  def pdf_file_path(pdfpre = nil)
    dir = File.join(Rails.root, pdf_file_dir(pdfpre))
    File.join(Rails.root, pdf_path(pdfpre, true))
  end
  
  
  def bucket_code
    super(DateTime.parse(self.created_at))
  end
  
  
  
  def self.write_pdf_from_html(html_string, path, locale, pdf_file_dir, force_write = false)
    if !File.exists?(path) || force_write
        pdf = WickedPdf.new.pdf_from_string(
        html_string,
        :disable_internal_links         => false,
        :disable_external_links         => false,
        :encoding => 'utf8',
        :locale=>locale
      )      
      FileUtils.mkdir_p(pdf_file_dir)
      File.open(path, "w") do |f|
        f << pdf.force_encoding('UTF-8')
      end
    end
  end
    
    
end