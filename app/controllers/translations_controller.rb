class TranslationsController < ApplicationController
  layout 'state_configuration'
  
  before_filter :get_translations
  
  def index
  end
  
  def show
    @locale = params[:locale]
    @translation = Translation.find(params[:id])
  end
  
  def submit
    @translation = Translation.find(params[:id])
    file = @translation.generate_yml(params[:locale], params[params[:locale]])
    send_data file, :filename=>"#{params[:id]}-#{params[:locale]}.yml", :type=>"text"
  end
  
private
  def get_translations
    @types = Translation.types
  end
  
end
