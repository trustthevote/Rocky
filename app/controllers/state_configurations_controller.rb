class StateConfigurationsController < ApplicationController
  layout 'state_configuration'
  
  def index
    @states = GeoState.all
    @state_importer = StateImporter.new
  end
  
  def show
    @state = GeoState.find(params[:id])    
  end
  
  
end
