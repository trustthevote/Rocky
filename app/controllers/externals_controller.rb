class ExternalsController < RegistrationStep
  CURRENT_STEP = 3

  def show
    super
    head :not_found unless @registrant.forwardable_to_electronic_registration?
  end

  def go
    find_registrant
    url = StateRegistrationSite.new(@registrant).transfer
    redirect_to url if url
  end
end
