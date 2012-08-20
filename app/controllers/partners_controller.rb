#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
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
    @text_link_html_b = %Q[<a href="https://register2.rockthevote.com#{root_path(:partner => partner_id)}">Register to Vote Here</a>]

    @image_link_html =
<<-HTML
<a href="https://#{request.host}#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}">
  <img src="#{partner_widget_url}" />
</a>
HTML
    @image_link_html_b =
<<-HTML
<a href="https://register2.rockthevote.com#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}">
  <img src="#{partner_widget_url}" />
</a>
HTML

    @floatbox_options = "width:618 height:max scrolling:yes"
    @image_overlay_html =
<<-HTML
<a href="https://#{request.host}#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}" class="floatbox" data-fb-options="#{@floatbox_options}">
  <img src="#{partner_widget_url}" />
</a>
<script type="text/javascript" src="https://#{request.host}#{widget_loader_path}"></script>
HTML
    @image_overlay_html_b =
<<-HTML
<a href="https://register2.rockthevote.com#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}" class="floatbox" data-fb-options="#{@floatbox_options}">
  <img src="#{partner_widget_url}" />
</a>
<script type="text/javascript" src="https://register2.rockthevote.com#{widget_loader_path}"></script>
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
    now = Time.now.to_s(:db).gsub(/\D/,'')
    send_data(current_partner.generate_registrants_csv, :filename => "registrations-#{now}.csv", :type => :csv)
  end

  protected

  def partner_id
    current_partner && current_partner.to_param
  end

  def partner_widget_url
    "http://#{request.host}/images/widget/#{@partner.widget_image}"
  end
  helper_method :partner_widget_url
end
