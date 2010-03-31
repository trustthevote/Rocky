class LogosController < PartnerBase
  before_filter :require_partner
  
  def show
    @partner = current_partner
  end
  # 
  # def update
  #   @partner = current_partner
  #   if @partner.update_attributes(:widget_image_name => params[:partner][:widget_image_name])
  #     flash[:success] = "You have updated your banner image."
  #     redirect_to partner_url
  #   else
  #     render "show"
  #   end
  # end
end
