class FinishesController < RegistrationStep
  CURRENT_STEP = 7

  def show
    find_registrant(:tell_friend)
    @root_url_escaped = CGI::escape(root_url)
    @registrant.tell_message ||=
      case @registrant.status.to_sym
      when :complete
        @status_text = CGI::escape("I just registered to vote and you can too!")
        I18n.t('email.tell_friend.body', :rtv_url => root_url(:source => "email"))
      when :under_18
        @status_text = CGI::escape("Make sure you register to vote. It's easy!")
        I18n.t('email.tell_friend_under_18.body', :rtv_url => root_url(:source => "email"))
      end
  end

end
