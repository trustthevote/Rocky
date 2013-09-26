class StateConfigurationsController < ApplicationController
  layout 'state_configuration'
  
  before_filter :get_state_importer
  
  def index
  end
  
  # def show
  #   @state = GeoState.find(params[:id])    
  # end
  
  def submit
    file = @state_importer.generate_yml(params[:config])
    if @state_importer.has_errors?
      render :action=>:show
    else
      submit_data(file)
    end    
  end
  
protected
  def get_state_importer
    @state_importer = StateImporter.new
  end
  
  def submit_data(file)
    # later this will be 'email'
    send_data file, :filename=>"new_states.yml", :type=>"text"
  end
  
  
end
