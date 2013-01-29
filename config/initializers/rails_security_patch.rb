ActionController::Base.param_parsers.delete(Mime::XML) 
ActiveSupport::JSON.backend = "JSONGem"