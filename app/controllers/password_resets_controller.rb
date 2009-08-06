class PasswordResetsController < ApplicationController
  layout "partners"

  before_filter :load_partner_using_perishable_token, :only => [:edit, :update]

  def new
  end

  def edit
  end

  def create
    if @partner = Partner.find_by_login(params[:login])
      @partner.deliver_password_reset_instructions!
      flash[:message] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to login_url
    else
      flash[:warning] = "No account was found with that username or email address"
      render "new"
    end
  end

  def update
    if @partner.update_attributes(params[:partner].try(:slice, :password, :password_confirmation))
      flash[:success] = "Password successfully updated. Please log in using new password."
      redirect_to login_url
    else
      render "edit"
    end
  end

  private
  def load_partner_using_perishable_token
    unless @partner = Partner.find_using_perishable_token(params[:id])
      flash[:warning] = "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process."
      redirect_to login_url
    end
  end
end
