class PartnersController < ApplicationController
  def show
    @widget_html = <<WIDGET_HTML
<div id="widget_box">
  <a href="#{host_url}/" id="rtv-widget-link">
    <img src="http://www.rockthevote.com/assets/images/pages/home/top-boxes/register_to_vote.jpg"></img>
  </a>
  <script type="text/javascript" src="#{widget_loader_partner_url(params[:id], :format => 'js')}"></script>
</div>
WIDGET_HTML

    @link_html = <<LINK_HTML
<a href="#{host_url}/">
  <img src="http://www.rockthevote.com/assets/images/pages/home/top-boxes/register_to_vote.jpg"></img>
</a>
LINK_HTML
  end

  def widget_loader
    @host = host_url
  end

  protected

  def host_url
    "#{request.protocol}#{request.host_with_port}"
  end
end
