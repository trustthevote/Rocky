class RegistrantsController < RegistrationStep
  CURRENT_STEP = 1

  # GET /widget_loader.js
  def widget_loader
    @host = host_url
  end

  # GET /registrants
  def landing
    find_partner
    options = {}
    options[:partner] = @partner.id
    options[:locale] = params[:locale] if params[:locale]
    options[:source] = params[:source] if params[:source]
    options.merge!(:protocol => "https") unless Rails.env.development?
    redirect_to new_registrant_url(options)
  end

  # GET /registrants/new
  def new
    set_up_locale
    @registrant = Registrant.new(:partner_id => @partner_id, :locale => @locale, :tracking_source => @source)
    render "show"
  end

  # POST /registrants
  def create
    set_up_locale
    @registrant = Registrant.new(params[:registrant].reverse_merge(
                                    :locale => @locale,
                                    :partner_id => @partner_id,
                                    :tracking_source => @source,
                                    :opt_in_sms => true, :opt_in_email => true))
    attempt_to_advance
  end

  protected

  def set_up_locale
    @locale = params[:locale] || 'en'
    I18n.locale = @locale.to_sym
    @alt_locale = (@locale == 'en' ? 'es' : 'en')
  end

  def advance_to_next_step
    @registrant.advance_to_step_1
  end

  def next_url
    registrant_step_2_url(@registrant)
  end

  def host_url
    "#{request.protocol}#{request.host_with_port}"
  end

end
