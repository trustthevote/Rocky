class QuestionsController < ApplicationController
  layout "partners"

  before_filter :require_partner, :only => [:edit, :update]

  def edit
    @partner = current_partner
  end

  def update
    @partner = current_partner
    if @partner.update_attributes(params[:partner])
      flash[:success] = "You have updated your survey questions."
      redirect_to partner_url
    else
      render "edit"
    end
  end
end
