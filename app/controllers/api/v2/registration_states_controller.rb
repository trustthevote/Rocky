class Api::V2::RegistrationStatesController < Api::V2::BaseController

  def index
    states = GeoState.states_with_online_registration
    jsonp @data = { :states => states.collect{|abbr| GeoState[abbr] }.map { |s| { :name => s.abbreviation, :url => s.online_reg_url(nil) } } }
  end

end
