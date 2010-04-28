class DownloadsController < RegistrationStep
  CURRENT_STEP = 6

  def show
    find_registrant(:download)
    if @registrant.pdf_ready?
      render "show"
    elsif @registrant.updated_at < 30.seconds.ago
      redirect_to registrant_finish_url(@registrant)
    else
      render "preparing"
    end
  end

end
