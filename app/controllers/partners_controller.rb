class PartnersController < PartnerBase
  before_filter :require_partner, :except => [:new, :create]

  ### public access

  def new
    if current_partner
      force_logout
      redirect_to new_partner_url
    else
      @partner = Partner.new
    end
  end

  def create
    @partner = Partner.new(params[:partner])
    if @partner.save
      flash[:success] = "Registered!"
      redirect_back_or_default partner_url
    else
      render "new"
    end
  end

  ### require login

  def edit
    @partner = current_partner
  end

  def update
    @partner = current_partner
    if @partner.update_attributes(params[:partner])
      flash[:success] = "You have updated your profile."
      redirect_to partner_url
    else
      render "edit"
    end
  end

  def show
    @partner = current_partner
    @stats_by_completion_date = @partner.registration_stats_completion_date
  end

  def embed_codes
    @partner = current_partner
    @text_link_html = %Q[<a href="https://#{request.host}#{root_path(:partner => partner_id)}">Register to Vote Here</a>]

    @image_link_html =
<<-HTML
<a href="https://#{request.host}#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}">
  <img src="http://#{request.host}/images/widget/#{@partner.widget_image}" />
</a>
HTML

    @image_overlay_html =
<<-HTML
<a href="https://#{request.host}#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}" class="floatbox" data-fb-options="width:604 height:max scrolling:no">
  <img src="http://#{request.host}/images/widget/#{@partner.widget_image}" />
</a>
<script type="text/javascript" src="https://#{request.host}#{widget_loader_path}"></script>
HTML

  end

  def statistics
    @partner = current_partner
    @stats_by_state = @partner.registration_stats_state
    @stats_by_completion_date = @partner.registration_stats_completion_date
    @stats_by_race = @partner.registration_stats_race
    @stats_by_gender = @partner.registration_stats_gender
    @stats_by_age = @partner.registration_stats_age
    @stats_by_party = @partner.registration_stats_party
  end

  def registrations
    send_data(current_partner.generate_registrants_csv, :filename => "registrations.csv", :type => :csv)
  end

  protected

  def partner_id
    current_partner && current_partner.to_param
  end
end
