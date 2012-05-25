class PartnerDetails

  def initialize(partner)
    @p = partner
  end

  def name
    @p.name
  end

  def organization
    @p.organization
  end

  def email
    @p.email
  end

  def whitelabel_status
    @p.whitelabeled? ? 'Yes' : 'No'
  end

  def assets_status
    @pt ||= PartnerEmailTemplates.new(@p)
    @pa ||= PartnerAssets.new(@p)

    [ "application.css - #{pm(@pa.present?('application.css'))}",
      "registration.css - #{pm(@pa.present?('registration.css'))}",
      "confirmation.en.html.erb - #{pm(@pt.present?('confirmation', 'en'))}",
      "confirmation.es.html.erb - #{pm(@pt.present?('confirmation', 'es'))}",
      "reminder.en.html.erb - #{pm(@pt.present?('reminder', 'en'))}",
      "reminder.es.html.erb - #{pm(@pt.present?('reminder', 'es'))}"
    ].join("<br/>")
  end

  private

  def pm(v)
    v ? 'present' : 'missing'
  end
end
