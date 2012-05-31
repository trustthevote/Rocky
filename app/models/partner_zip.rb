require 'zip/zip'

class PartnerZip
  
  attr_accessor :tmp_file, :destination, :there_are_errors
  attr_reader :errors
  
  def self.tmp_root
    File.join(RAILS_ROOT, 'tmp', 'partner_uploads')
  end
  
  def self.get_tmp_path
    File.join(self.tmp_root, DateTime.now.strftime("%Y_%m_%d_%H_%M_%S_%L"))
  end
  
  
  def initialize(tmp_file)
    @tmp_file = tmp_file
    @destination = PartnerZip.get_tmp_path
    @errors = []
    @there_are_errors = false
    if @tmp_file
      Zip::ZipFile.open(@tmp_file.path) { |zip_file|
         zip_file.each { |f|
           f_path=File.join(@destination, f.name)
           FileUtils.mkdir_p(File.dirname(f_path))
           zip_file.extract(f, f_path) unless File.exist?(f_path)
         }
        }
    end
  end
  
  def create
    unless @tmp_file
      add_error("ZIP file not uploaded") and return false
    end
    
    @csv_file = detect_csv
    unless @csv_file
      add_error("The CSV file is missing") and return false
    end
    
    new_partners = get_partners_from_csv
    return false if self.there_are_errors

    new_partners.each do |p|
      p.save!
      if !p.tmp_asset_directory.blank?
        load_tmp_assets(p)
      end      
    end
    return true
  ensure
    remove_tmp_directory
  end
  
  def columns
    [:username, :email, :name, :organization, :url, 
      :address, :city, :state_id, :zip_code, :phone, 
      :survey_question_1_en, :survey_question_1_es, 
      :survey_question_2_en, :survey_question_2_es, 
      :whitelabeled, :rtv_email_opt_in, :rtv_sms_opt_in, :ask_for_volunteers, 
      :partner_email_opt_in, :partner_sms_opt_in, :partner_ask_for_volunteers, 
      :tmp_asset_directory]    
  end
  
  def error_messages
    @errors.collect {|err|
      if err.is_a?(Array)
        "#{err[0]} <ul><li>#{err[1].full_messages.join("</li><li>")}</li></ul>"
      else
        err
      end
    }.join("<br/>")
  end
  
  def new_record?
    true
  end
  
private

  def detect_csv
    csv_file = nil
    Dir.entries(self.destination).each do |entry|
      if entry =~ /\.csv$/
        csv_file = File.join(self.destination, entry)
        break;
      end
    end
    return csv_file
  end

  def get_partners_from_csv
    new_partners = []
    row_idx = 1
    FasterCSV.foreach(@csv_file, {:headers=>true}) do |row|
      if row.size != columns.size
        add_error("Row #{row_idx} column count is #{row.size} and should be #{columns.size}")
      end
      
      #Create a data hash for a Partner instance, mapping to the #columns values
      data = {}
      columns.each_with_index do |col,i|
        data[col] = row[i].to_s.strip
      end
      
      #give some flexibility to the state_id field
      if data[:state_id].to_i == 0
        state = GeoState.find_by_abbreviation(data[:state_id])
        data[:state_id] = state.id if state
      end

      p = Partner.new(data)
      #assign a random password. Imported partners will need to go through the forgot password process      
      p.password = Authlogic::Random::friendly_token
      p.password_confirmation = p.password
      
      new_partners << p
      
      if !p.valid?
        add_error("Row #{row_idx} is invalid", p)
      end
      if p.whitelabeled && !File.exists?(tmp_application_css_path(p))
        add_error("Row #{row_idx} is whitelabeled and missing application.css in /#{p.tmp_asset_directory}", p)
      end
      if p.whitelabeled && !File.exists?(tmp_registration_css_path(p))
        add_error("Row #{row_idx} is whitelabeled and missing registration.css in /#{p.tmp_asset_directory}", p)
      end
      row_idx +=1
    end

    return new_partners
  end
  
  # Set CSS files, read in email templates, copy all other assets
  def load_tmp_assets(p)
    if p.whitelabeled
      paf = PartnerAssetsFolder.new(p)
      paf.update_css('application', File.open(tmp_application_css_path(p)))
      paf.update_css('registration', File.open(tmp_registration_css_path(p)))
      Dir.entries(tmp_asset_path(p)).each do |fname|
        # only copy asset if not specifically dealt with above and not an email template file
        if not_expected_file(fname)
          paf.update_asset(fname, File.open(File.join(tmp_asset_path(p), fname)))
        end
      end
    end
    # Look for the expected EmailTemplate files
    EmailTemplate::TEMPLATE_NAMES.each do |file_name,label|
      if File.exists?(File.join(tmp_asset_path(p), file_name))
        File.open(File.join(tmp_asset_path(p), file_name)) do |template_file|
          EmailTemplate.set(p, file_name, template_file.read)
        end
      end
    end
  end
  
  def tmp_asset_path(p)
    File.join(self.destination, p.tmp_asset_directory)
  end
  
  def tmp_application_css_path(p)
    File.join(tmp_asset_path(p), PartnerAssets::APP_CSS)
  end
  def tmp_registration_css_path(p)
    File.join(tmp_asset_path(p), PartnerAssets::REG_CSS)
  end
  
  def remove_tmp_directory
    if File.exists?(self.destination)
      FileUtils.remove_entry_secure(self.destination, true)
    end  
  end
  
  def add_error(message, partner=nil)
    self.there_are_errors = true
    if partner
      self.errors << [message, partner.errors]
    else
      self.errors << message
    end
  end
  
  def not_expected_file(fname)
    !File.directory?(fname) && 
      fname != PartnerAssets::APP_CSS &&
      fname != PartnerAssets::REG_CSS && 
      !(fname =~ /\.e[ns]$/) # not a email template
  end
  
end