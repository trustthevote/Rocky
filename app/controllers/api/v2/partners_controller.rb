class Api::V2::PartnersController < ApplicationController
  def show
    query = {
      :partner_id       => params[:partner_id],
      :partner_api_key => params[:partner_api_key],
    }

    jsonp V2::PartnerService.find(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end
  
end
