class DownloadsController < RegistrationStep
  CURRENT_STEP = 6

  def show
    find_registrant(:download)
    render "preparing" unless @registrant.pdf_ready?
  end

end
