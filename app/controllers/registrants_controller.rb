class RegistrantsController < ApplicationController
  # GET /registrants/new
  def new
    partner_id = params[:partner] || Partner.default_id
    locale = params[:locale] || 'en'
    I18n.locale = locale.to_sym
    @registrant = Registrant.new(:partner_id => partner_id, :locale => locale)
  end

  # POST /registrants
  def create
    @registrant = Registrant.new(params[:registrant])
    if @registrant.advance_to_step_1!
      flash[:success] = I18n.t "txt.flash.eligible"
      redirect_to registrant_step_2_path(@registrant)
    else
      render "new"
    end
  end
end
