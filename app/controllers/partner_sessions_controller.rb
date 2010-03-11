class PartnerSessionsController < PartnerBase
  def new
    @partner_session = PartnerSession.new
  end

  def create
    @partner_session = PartnerSession.new(params[:partner_session])
    if @partner_session.save
      flash[:success] = "Login successful!"
      redirect_back_or_default partner_url
    else
      render :action => :new
    end
  end

  def destroy
    current_partner_session.destroy
    flash[:success] = "Logged out"
    redirect_back_or_default login_url
  end
end
