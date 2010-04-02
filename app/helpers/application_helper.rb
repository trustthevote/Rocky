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
      messages << content_tag(:li, flash[key], :class => "flash-#{key}") if flash[key]
    end
    content_tag(:ul, messages.join("\n"), :class => "flash")
  end

  def clippy(text, bgcolor='#dddddd')
    html = <<-HTML
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    HTML
  end

  def partner_locale_options(partner, locale, source)
    opts = {}
    opts[:partner] = partner unless partner == Partner.default_id
    opts[:locale]  = locale  unless locale == "en"
    opts[:source]  = source  unless source.blank?
    opts
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
    has_error = form.object.errors.on(field) ? "has_error" : nil
    content_tag(:div, form.send( selector, field, {:size => nil}.merge(options) ), :class => has_error)
  end

  def select_div(form, field, contents, options={})
    has_error = form.object.errors.on(field) ? "has_error" : nil
    content_tag(:div, form.select(field, contents, options), :class => has_error)
  end

  def rollover_button(name, text)
    <<-HTML
      <div class="button">
        <a class="button_#{name}_#{I18n.locale}" href="#"><button type="submit" id="registrant_submit"><span>#{text}</span></button></a>
      </div>
    HTML
  end

  def rollover_image_link(name, text, url, options={})
    optional_attrs = options.inject("") {|s,(k,v)| s << %Q[ #{k}="#{v}"] }
    <<-HTML
      <span class="button">
        <a class="button_#{name}_#{I18n.locale}" href="#{url}"#{optional_attrs}><span>#{text}</span></a>
      </span>
    HTML
  end

  def partner_rollover_button(name, text)
    <<-HTML
      <div class="button">
        <a class="button_#{name}" href="#"><button type="submit" id="partner_submit"><span>#{text}</span></button></a>
      </div>
    HTML
  end

  def rtv_partner_url(partner)
    url = "https://register.rockthevote.com/registrants/new"
    url << "?partner=#{partner.id}" unless partner.id == Partner.default_id
    CGI.escape(url)
  end
end
