class ExternalsController < RegistrationStep
  CURRENT_STEP = 3

  # show is in superclass

  def go
    find_registrant
    url = StateRegistrationSite.new(@registrant).transfer
    redirect_to url if url
  end
end
