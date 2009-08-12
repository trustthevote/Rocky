class PartnersController < ApplicationController
  before_filter :require_partner, :only => [:show, :edit, :update]

  def new
    @partner = Partner.new
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
    @widget_html = <<-HTML
<div id="widget_box">
  <a href="#{new_registrant_url(:partner => partner_id)}" id="rtv-widget-link">
    <img src="http://www.rockthevote.com/assets/images/pages/home/top-boxes/register_to_vote.jpg"></img>
  </a>
  <script type="text/javascript" src="#{widget_loader_url(partner_id, :format => 'js')}"></script>
</div>
HTML

    @link_html = <<-HTML
<a href="#{new_registrant_url(:partner => partner_id)}">
  <img src="http://www.rockthevote.com/assets/images/pages/home/top-boxes/register_to_vote.jpg"></img>
</a>
HTML
  end

  def statistics
    @partner = current_partner
    @stats_by_state = @partner.registration_stats_state
    @stats_by_race = @partner.registration_stats_race
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
