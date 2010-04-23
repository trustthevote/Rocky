class RemindersController < RegistrationStep
  CURRENT_STEP = 8
  def show
    find_registrant(:stop_reminders)
    @registrant.update_attributes(:reminders_left => 0)
  end
end
