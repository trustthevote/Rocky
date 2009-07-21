class PartnerSessionsController < ApplicationController
  # before_filter :require_no_user, :only => [:new, :create]
  # before_filter :require_user, :only => :destroy

  def new
    @partner_session = PartnerSession.new
  end

  def create
    @partner_session = PartnerSession.new(params[:partner_session])
    if @partner_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default dashboard_url
    else
      # need flash
      render :action => :new
    end
  end

  # def destroy
  #   current_user_session.destroy
  #   flash[:notice] = "Logout successful!"
  #   redirect_back_or_default new_user_session_url
  # end
  # 
end
