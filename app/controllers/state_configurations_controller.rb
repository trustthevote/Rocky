class StateConfigurationsController < ApplicationController
  layout 'state_configuration'
  
  before_filter :get_state_importer
  before_filter :disallow_production
  
  before_filter :authenticate, :if => lambda { !%w{ development test }.include?(Rails.env) }
  
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
      File.open(StateImporter.tmp_file_path, "w+") do |f|
        f.write file
      end
      submit_data(file)
    end    
  end
  
protected
  def disallow_production
    if Rails.env.production?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def get_state_importer
    @state_importer = StateImporter.new
  end
  
  def submit_data(file)
    # later this will be 'email'
    #send_data file, :filename=>"new_states.yml", :type=>"text"
    ConfigMailer.state_config_file(file, "updated-states.yml").deliver
    
  end
  
  private

  def authenticate
    authenticate_or_request_with_http_basic("Settings UI") do |user, password|
      pass = Settings.admin_password
      pass.present? && user == 'rtvdemo' && password == 'bullwinkle'
    end
  end
  
  
end
