#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
require 'zip/zip'

class PartnerZip
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  
  attr_accessor :tmp_file, :destination, :original_destination, :there_are_errors
  attr_reader :errors
  
  def self.tmp_root
    File.join(Rails.root, 'tmp', 'partner_uploads')
  end
  
  def self.get_tmp_path
    File.join(self.tmp_root, DateTime.now.strftime("%Y_%m_%d_%H_%M_%S_%L"))
  end
  
  
  def initialize(tmp_file)
    @tmp_file = tmp_file
    @destination = PartnerZip.get_tmp_path
    @original_destination = @destination
    @errors = []
    @there_are_errors = false
    if @tmp_file
      # from http://www.markhneedham.com/blog/2008/10/02/ruby-unzipping-a-file-using-rubyzip/
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
    
    #raise self.errors[0][1].messages.to_s if self.there_are_errors
    
    return false if self.there_are_errors
    
    check_for_subdirectories(new_partners)
    
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
  
  def self.columns
    [:username, :email, :name, :organization, :url, 
      :address, :city, :state_id, :state, :zip_code, :phone, 
      :survey_question_1_en, :survey_question_1_es, 
      :survey_question_2_en, :survey_question_2_es, 
      :whitelabeled, :from_email, :finish_iframe_url,
      :rtv_email_opt_in, :rtv_sms_opt_in, :ask_for_volunteers, 
      :partner_email_opt_in, :partner_sms_opt_in, :partner_ask_for_volunteers, 
      :tmp_asset_directory, :asset_directory, :registration_instructions_url, :external_tracking_snippet,
      :widget_image,:privacy_url,:is_government_partner,:government_partner_state,:government_partner_state_id,:government_partner_zip_codes]    
  end
  
  def self.allowed_columns
    columns + RockyConf.enabled_locales.collect do |locale|
      unless ['en', 'es'].include?(locale.to_s)
        locale = locale.underscore
        [1,2].collect do |num|
          "survey_question_#{num}_#{locale}".to_sym
        end
      end
    end.flatten.compact
  end
  
  def allowed_columns
    self.class.allowed_columns
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
  
  def persisted?
    false
  end
  
private

  def detect_csv
    csv_file = nil
    directories = []
    Dir.entries(self.destination).each do |entry|
      if entry =~ /\.csv$/i
        csv_file = File.join(self.destination, entry)
        break
      elsif File.directory?(File.join(self.destination, entry)) && !(entry =~ /^[\._]/)
        directories << entry
      end
    end
    if !csv_file
      prev_destination = destination
      directories.each do |sub_dir|
        @destination = File.join(prev_destination, sub_dir)
        csv_file = detect_csv
        break if csv_file
      end
    end
    return csv_file
  end

  def get_partners_from_csv
    new_partners = []
    imports = CSV.read(@csv_file, {:headers=>true,  :encoding => 'windows-1251:utf-8'})
    imports.headers.each do |h|
      if !allowed_columns.include?(h.to_s.strip.to_sym)
        add_error("Header #{h} is not an allowed column")
      end
    end
    unless there_are_errors
      imports.each_with_index do |row, i|

        #Create a data hash for a Partner instance, mapping to the #columns values
        data = {}
        row.each {|k,v| data[k.strip.to_sym] = v.to_s.strip }
      
        #give some flexibility to the state_id fielde
        if data[:state_id].to_i == 0
          state = GeoState.find_by_abbreviation(data[:state_id])
          if state
            data[:state_id] = state.id 
          else
            state = GeoState.find_by_abbreviation(data.delete(:state))
            data[:state_id] = state.id if state
          end
        end
        if data[:government_partner_state_id].to_i == 0
          state = GeoState.find_by_abbreviation(data[:government_partner_state_id])
          if state
            data[:government_partner_state_id] = state.id 
          else
            state = GeoState.find_by_abbreviation(data.delete(:government_partner_state))
            data[:government_partner_state_id] = state.id if state
          end
        end
        
        if data.has_key?(:is_government_partner) && data[:is_government_partner].blank?
          data.delete(:is_government_partner)
        end
        
        data[:government_partner_zip_code_list] = data.delete(:government_partner_zip_codes)
        
        if (tad = data.delete(:asset_directory)) && data[:tmp_asset_directory].blank?
          data[:tmp_asset_directory] = tad
        end

        p = Partner.new(data)
        #assign a random password. Imported partners will need to go through the forgot password process      
        p.password = Authlogic::Random::friendly_token
        p.password_confirmation = p.password
      
        new_partners << p
      
        if !p.valid?
          add_error("Row #{i + 1} is invalid", p)
        end
      end
    end
    return new_partners
  end
  
  def check_for_subdirectories(new_partners)
    new_partners.each do |p|
      if !p.tmp_asset_directory.blank?
        Dir.entries(tmp_asset_path(p)).each do |fname|
          # only copy asset if not specifically dealt with above and not an email template file
          if not_expected_file(fname) && File.directory?(File.join(tmp_asset_path(p), fname))
            add_error("#{File.join(p.tmp_asset_directory, fname)} is a directory")
          end
        end
      end
    end
  end
  
  # Set CSS files, read in email templates, copy all other assets
  def load_tmp_assets(p)
    # check if there are subdirectoy issues
    
    if p.whitelabeled
      paf = PartnerAssetsFolder.new(p)
      paf.update_css('application', File.open(tmp_application_css_path(p))) if File.exists?(tmp_application_css_path(p))
      paf.update_css('registration', File.open(tmp_registration_css_path(p))) if File.exists?(tmp_registration_css_path(p))
      paf.update_css('partner', File.open(tmp_partner_css_path(p))) if File.exists?(tmp_partner_css_path(p))
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
  def tmp_partner_css_path(p)
    File.join(tmp_asset_path(p), PartnerAssets::PART_CSS)
  end
  
  def remove_tmp_directory
    if File.exists?(self.original_destination)
      FileUtils.remove_entry_secure(self.original_destination, true)
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