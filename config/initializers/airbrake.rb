Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
  config.params_filters << "id_number"
  config.params_filters << "state_id_number"
end
