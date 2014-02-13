class TranslationsController < ApplicationController
  layout 'state_configuration'
  
  before_filter :disallow_production
  before_filter :get_translations
  before_filter :get_locale_and_translation, :except=>[:index, :all_languages, :preview_pdf]
  

  def index
  end
  
  def show
  end
  
  def preview_pdf
    @locale = params[:id]
    @state = (params[:state] ? GeoState[params[:state]]  : GeoState.first ) || GeoState.first
    @registrant = Registrant.new
    @registrant.home_state = @state
    @registrant.date_of_birth = Date.parse("01-01-1900")
    @registrant.id = 111
    @registrant.locale = @locale
    I18n.locale = @locale
        
    respond_to do |format|
      format.html do
        render :layout=>'nvra.html.haml', :template=>'registrants/registrant_pdf.html.haml'
      end
      format.pdf do
        render :pdf => "registration", 
          :template => 'registrants/registrant_pdf.html.haml', 
          :layout => 'nvra.html.haml', :locale=>@locale
      end
    end
    
  end
  
  
  def save
    file = @translation.generate_yml(params[:locale], params[params[:locale]])
  end
  
  def submit
    file = @translation.generate_yml(params[:locale], params[params[:locale]])
    if params[:save]
      begin
        File.open(@translation.tmp_file_path(params[:id],params[:locale]), "w+") do |f|
          f.write file
        end
        flash[:notice] = "#{Translation.language_name(@locale)} '#{@translation.name}' translations saved"
      rescue
        flash[:notice] = "Error saving #{Translation.language_name(@locale)} '#{@translation.name}' translations"
      end
      render :action=>:show    
    else      
      if @translation.has_errors?
        render :action=>:show
      else
        submit_data(file, params[:id], params[:locale])
      end
    end
  end
  
  def all_languages
    @enabled_locales = RockyConf.enabled_locales
    @all_locales = I18n.available_locales
    respond_to do |format|
      format.html do
        render :layout=>'nvra.html.haml'
      end
      format.pdf do
        render :pdf => "all_languages", 
          :template => 'translations/all_languages.html.haml', 
          :layout => 'nvra.html.haml'
      end
    end
  end
  
private
  def disallow_production
    if Rails.env.production?
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def get_translations
    @types = Translation.types
  end
  
  def get_locale_and_translation
    @locale = params[:locale]
    @translation = Translation.find(params[:id])
  end
  
  def submit_data(file, group_name, locale)
    # later this will be 'email'
    #Send an email
    ConfigMailer.translation_file(file, "#{group_name}-#{locale}.yml").deliver
    #send_data file.to_s, :filename=>"#{group_name}-#{locale}.yml", :type=>"text"
  end



  
end
