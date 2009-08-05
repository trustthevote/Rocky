class RegistrantsController < ApplicationController
  include RegistrationStep

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
    @registrant.advance_to_step_1

    if @registrant.valid?
      @registrant.save_or_reject!
      if @registrant.eligible?
        redirect_to registrant_step_2_url(@registrant)
      else
        redirect_to ineligible_registrant_url(@registrant)
      end
    else
      render "new"
    end
  end

  # GET /registrants/:id
  def show
    find_registrant
    render "new"
  end

  # PUT /registrants/:id
  def update
    find_registrant
    @registrant.attributes = params[:registrant]
    @registrant.advance_to_step_1

    if @registrant.valid?
      @registrant.save_or_reject!
      if @registrant.eligible?
        redirect_to registrant_step_2_url(@registrant)
      else
        redirect_to ineligible_registrant_url(@registrant)
      end
    else
      render "new"
    end
  end

  def ineligible
    find_registrant
  end

  def download
    find_registrant
  end

  def pdf
    find_registrant
    @registrant.generate_pdf!
    # TODO: serve this as a static asset
    send_file(@registrant.pdf_path, :type => :pdf, :filename => "voter_registration_form.pdf")
  end
end
