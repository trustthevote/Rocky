class LogosController < PartnerBase
  before_filter :require_partner

  def show
    @partner = current_partner
  end

  def update
    @partner = current_partner
    if @partner.update_attributes(:logo => params[:partner][:logo])
      flash[:success] = "You have updated your logo."
      redirect_to partner_logo_url
    else
      render "show"
    end
  end
end
