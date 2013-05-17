class LocalizationsController < ApplicationController
  layout 'state_configuration'
  
  def index
    @localizations = I18n.backend.send(:translations)
  end
  
end
