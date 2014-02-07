module ApplicationHelper

  # flash_messages
  # use to display specified flash messages
  # defaults to standard set: [:success, :message, :warning]
  # example:
  #   <%= flash_messages %>
  # example with other keys:
  #   <%= flash_messages :notice, :violation %>
  # renders like:
  #  <ul class="flash">
  #   <li class="flash-success">Positive - successful action</li>
  #   <li class="flash-message">Neutral - reminders, status</li>
  #   <li class="flash-warning">Negative - error, unsuccessful action</li>
  #  </ul>
  def flash_messages(*keys)
    keys = [:success, :message, :warning] if keys.empty?
    messages = []
    keys.each do |key|
      messages << content_tag(:li, flash[key], :class => "flash-#{key}").html_safe if flash[key]
    end
    if messages.empty?
       content_tag(:div, "", :class => "flash").html_safe
    else
      content_tag(:ul, messages.join("\n").html_safe, :class => "flash").html_safe
    end
  end

  def partner_locale_options(partner, locale, source)
    opts = {}
    opts[:partner] = partner unless partner == Partner::DEFAULT_ID
    opts[:locale]  = locale  unless locale == "en"
    opts[:source]  = source  unless source.blank?
    opts
  end

  def partner_css(partner = @partner)
    wl = partner && partner.whitelabeled?

    stylesheets = []
    stylesheets << (wl && partner.application_css_present? ? partner.application_css_url : "application")
    stylesheets << (wl && partner.registration_css_present? ? partner.registration_css_url : "registration")
    stylesheets += registrant_css
    stylesheets << partner.partner_css_url if wl && partner.partner_css_present?
    stylesheets
  end
  
  def registrant_css(registrant = @registrant, locale = @locale)
    stylesheets = []
    locale ||= registrant ? registrant.locale : nil
    if !locale.nil?
      stylesheets << "locales/#{locale}" if Translation.has_css?(locale)
    end
    stylesheets
  end

  def yes_no_options
    [['', nil], ['Yes', true], ['No', false]]
  end

  def octothorpe(unit)
    unit =~ /^\d+$/ ? "##{unit}" : unit
  end

  def progress_indicator
    (1..5).map do |step_index|
      progress = case step_index <=> controller.current_step
      when -1 then "progress-done"
      when 0 then "progress-current"
      else "progress-todo"
      end
      content_tag :li, step_index, :class => progress
    end.join
  end

  def tooltip_tag(tooltip_id, content = t("txt.registration.tooltips.#{tooltip_id}"))
    image_tag 'buttons/help_icon.gif', :mouseover => 'buttons/help_icon_over.gif', :alt => t('txt.button.help'),
      :class => 'tooltip', :id => "tooltip-#{tooltip_id}",
      :title => content
  end

  def field_div(form, field, options={})
    kind = options.delete(:kind) || "text"
    selector = "#{kind}_field"
    has_error = !form.object.errors[field].empty? ? "has_error" : nil
    content_tag(:div, form.send( selector, field, {:size => nil}.merge(options) ).html_safe, :class => has_error).html_safe
  end

  def select_div(form, field, contents, options={})
    has_error = !form.object.errors[field].empty? ? "has_error" : nil
    content_tag(:div, form.select(field, contents, options), :class => has_error)
  end

  def rollover_button(name, text, button_options={})
    button_options[:id] ||= "registrant_submit"
    html =<<-HTML
      <div class="button rollover_button">
        <a class="button_#{name}_#{I18n.locale} button_#{name}" href="#">
          <button type="submit" id="#{button_options.delete(:id)}" #{button_options.collect{|k,v| "#{k}=\"#{v}\"" }.join(" ")}>
            <span>#{text}</span>
          </button>
        </a>
      </div>
    HTML
    html.html_safe
  end

  def rollover_image_link(name, text, url, options={})
    optional_attrs = options.inject("") {|s,(k,v)| s << %Q[ #{k}="#{v}"] }
    html =<<-HTML
      <span class="button rollover_button">
        <a class="button_#{name}_#{I18n.locale} button_#{name}" href="#{url}"#{optional_attrs}><span>#{text}</span></a>
      </span>
    HTML
    html.html_safe
  end

  def partner_rollover_button(name, text)
    html =<<-HTML
      <div class="button rollover_button">
        <a class="button_#{name}" href="#"><button type="submit" id="partner_submit"><span>#{text}</span></button></a>
      </div>
    HTML
    html.html_safe
  end
  
end
