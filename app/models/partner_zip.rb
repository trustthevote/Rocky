require 'zip/zip'

class PartnerZip
  
  attr_accessor :tmp_file, :destination
  attr_reader :errors
  
  def self.tmp_path
    File.join(RAILS_ROOT, 'tmp', 'partner_uploads', DateTime.now.strftime("%Y_%m_%d_%H_%M_%S"))
  end
  
  
  def initialize(tmp_file)
    @tmp_file = tmp_file
    @destination = PartnerZip.tmp_path
    @errors = []
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
    return false unless @tmp_file
    @csv_file = nil
    Dir.entries(@destination).each do |entry|
      if entry =~ /\.csv$/
        @csv_file = File.join(@destination, entry)
        break;
      end
    end
    unless @csv_file
      @errors << "The CSV file is missing"
      return false
    end
    new_partners = []
    all_valid = true
    row_idx = 1
    FasterCSV.foreach(@csv_file, {:headers=>true}) do |row|
      raise 'Row missing data' if row.size != columns.size
      #Create a data hash
      data = {}
      columns.each_with_index do |col,i|
        data[col] = row[i].to_s.strip
      end
      if data[:state_id].to_i == 0
        state = GeoState.find_by_abbreviation(data[:state_id])
        data[:state_id] = state.id if state
      end
      p = Partner.new(data)
      p.password = Authlogic::Random::friendly_token
      p.password_confirmation = p.password
      new_partners << p
      if !p.valid?
        all_valid = false
        @errors << ["Row #{row_idx} is invalid", p.errors]
      end
      if p.whitelabeled && !File.exists?(File.join(@destination, p.tmp_asset_directory, 'application.css'))
        all_valid = false
        @errors << ["Row #{row_idx} is whitelabeled and missing application.css in /#{p.tmp_asset_directory}", p.errors]
      end
      if p.whitelabeled && !File.exists?(File.join(@destination, p.tmp_asset_directory, 'registration.css'))
        all_valid = false
        @errors << ["Row #{row_idx} is whitelabeled and missing registration.css in /#{p.tmp_asset_directory}", p.errors]
      end
      row_idx +=1
    end
    return false unless all_valid
    new_partners.each do |p|
      p.save!
      if p.whitelabeled
        paf = PartnerAssetsFolder.new(p)
        paf.update_css('application', File.open(File.join(@destination, p.tmp_asset_directory, 'application.css')))
        paf.update_css('registration', File.open(File.join(@destination, p.tmp_asset_directory, 'registration.css')))
        Dir.entries(File.join(@destination, p.tmp_asset_directory)).each do |fname|
          if !File.directory?(fname) && fname != "application.css" && fname != "registration.css"
            paf.update_asset(fname, File.open(File.join(@destination, p.tmp_asset_directory, fname)))
          end
        end
      end
    end
    return true
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
  
  
  def new_record?
    true
  end
  
  
end