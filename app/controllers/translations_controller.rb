class TranslationsController < ApplicationController
  layout 'state_configuration'
  
  def index
  end
  
  def show
    @translation = Translation.find(params[:id])
  end
  
  
end
