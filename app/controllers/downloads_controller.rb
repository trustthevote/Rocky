class DownloadsController < ApplicationController
  include RegistrationStep
  CURRENT_STEP = 6

  def show
    find_registrant(:download)
  end

end