module RegistrationStep
  
  protected
  
  def find_registrant
    @registrant = Registrant.find(params[:registrant_id])
    I18n.locale = @registrant.locale
  end
end

