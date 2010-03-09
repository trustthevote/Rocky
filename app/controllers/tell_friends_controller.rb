class TellFriendsController < ApplicationController
  include RegistrationStep

  def create
    find_registrant(:tell_friend)
    @registrant.attributes = params[:tell_friend] if params[:tell_friend]
    @registrant.telling_friends = true
    @email_sent = @registrant.valid?
    # registrant sends email as side-effect of there being valid tell-friend params
    render "registrants/finish"
  end

  def current_step
    7
  end

  hide_action :current_step

  private

  def advance_to_next_step
    # noop
  end

  def next_url
    finish_registrant_url(@registrant)
  end
end
