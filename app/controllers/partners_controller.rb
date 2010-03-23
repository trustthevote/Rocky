class PartnersController < PartnerBase
  before_filter :require_partner, :only => [:show, :edit, :update]

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
    @link_html = <<-HTML
<a href="https://#{request.host}#{new_registrant_path(:partner => partner_id)}" class="floatbox" data-fb-options="width:604 height:max scrolling:no">
  <img src="http://#{request.host}/images/widget/rtv-big.jpg"></img>
</a>
<script type="text/javascript" src="https://#{request.host}#{widget_loader_path(:id => partner_id, :format => 'js')}"></script>
HTML
  end

  def statistics
    @partner = current_partner
    @stats_by_state = @partner.registration_stats_state
    @stats_by_completion_date = @partner.registration_stats_completion_date
    @stats_by_race = @partner.registration_stats_race
    @stats_by_gender = @partner.registration_stats_gender
    @stats_by_age = @partner.registration_stats_age
  end

  def registrations
    send_data(current_partner.generate_registrants_csv, :filename => "registrations.csv", :type => :csv)
  end

  def widget_loader
    @partner_id = params[:id]
    @host = host_url
  end

  protected

  def host_url
    "#{request.protocol}#{request.host_with_port}"
  end
  
  def partner_id
    current_partner && current_partner.to_param
  end
end
