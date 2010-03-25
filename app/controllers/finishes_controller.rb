class FinishesController < RegistrationStep
  CURRENT_STEP = 7

  def show
    find_registrant(:tell_friend)
    @registrant.tell_message ||=
      case @registrant.status.to_sym
      when :complete
        I18n.t('email.tell_friend.body', :rtv_url => root_url(:source => "email"))
      when :under_18
        I18n.t('email.tell_friend_under_18.body', :rtv_url => root_url(:source => "email"))
      end
  end

end
