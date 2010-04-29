class FinishesController < RegistrationStep
  CURRENT_STEP = 7

  def show
    find_registrant(:tell_friend)
    if params[:reminders]
      @registrant.update_attributes(:reminders_left => 0)
      @stop_reminders = true
    end
    @root_url_escaped = CGI::escape(root_url)
    @registrant.tell_message ||=
      case @registrant.status.to_sym
      when :under_18
        I18n.t('email.tell_friend_under_18.body', :rtv_url => root_url(:source => "email"))
      else
        I18n.t('email.tell_friend.body', :rtv_url => root_url(:source => "email"))
      end
  end

end
