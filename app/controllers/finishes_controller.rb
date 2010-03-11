class FinishesController < ApplicationController
  include RegistrationStep
  CURRENT_STEP = 7

  def show
    find_registrant(:tell_friend)
  end

end
