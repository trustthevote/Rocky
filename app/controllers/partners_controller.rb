class PartnersController < ApplicationController
  
  def widget_loader
    @host = "#{request.protocol}#{request.host_with_port}"
    # render "widget_loader.js.erb"
  end
end
