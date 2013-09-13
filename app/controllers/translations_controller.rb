class TranslationsController < ApplicationController
  layout 'state_configuration'
  
  before_filter :disallow_production
  before_filter :get_translations
  before_filter :get_locale_and_translation, :except=>:index
  
  def index
  end
  
  def show
  end
  
  def submit
    file = @translation.generate_yml(params[:locale], params[params[:locale]])
    if @translation.has_errors?
      render :action=>:show
    else
      submit_data(file, params[:id], params[:locale])
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
