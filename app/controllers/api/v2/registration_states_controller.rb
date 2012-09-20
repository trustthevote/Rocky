class Api::V2::RegistrationStatesController < Api::V2::BaseController

  def index
    states = GeoState.all
    jsonp @data = { :states => GeoState.all.map { |s| { :name => s.abbreviation, :url => s.registrar_url } } }
  end

end
