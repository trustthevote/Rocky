module Mergable
  def pdf_date_of_birth
    date_of_birth.to_s(:month_day_year)
  end

  def pdf_race
    if requires_race? && race != I18n.t('txt.registration.races').last
      race
    else
      ""
    end
  end

  def pdf_barcode
    user_code = id.to_s(36)
    padding = "0" * (6 - user_code.length) rescue ""
    "*#{BARCODE_PREFIX}-#{padding}#{user_code}*".upcase
  end

  def to_xfdf
    ERB.new(XFDF_TEMPLATE).result(binding)
  end

  XFDF_TEMPLATE = <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
  <f href=""/>
  <ids original="" modified=""/>
  <fields>
    <field name="us_citizen">
      <value><%= us_citizen? ? 'Yes' : 'No' %></value>
    </field>
    <field name="will_be_18_by_election">
      <value><%= will_be_18_by_election? ? 'Yes' : 'No' %></value>
    </field>
    <field name="name.title">
      <value><%= name_title %></value>
    </field>
    <field name="name.first">
      <value><%= first_name %></value>
    </field>
    <field name="name.middle">
      <value><%= middle_name %></value>
    </field>
    <field name="name.last">
      <value><%= last_name %></value>
    </field>
    <field name="name.suffix">
      <value><%= name_suffix %></value>
    </field>
    <field name="home_address.street">
      <value><%= home_address %></value>
    </field>
    <field name="home_address.unit">
      <value><%= home_unit %></value>
    </field>
    <field name="home_address.city">
      <value><%= home_city %></value>
    </field>
    <field name="home_address.state">
      <value><%= home_state.abbreviation %></value>
    </field>
    <field name="home_address.zip_code">
      <value><%= home_zip_code %></value>
    </field>
    <field name="mailing_address.street">
      <value><%= mailing_address %> <%= mailing_unit %></value>
    </field>
    <field name="mailing_address.city">
      <value><%= mailing_city %></value>
    </field>
    <field name="mailing_address.state">
      <value><%= mailing_state_abbrev %></value>
    </field>
    <field name="mailing_address.zip_code">
      <value><%= mailing_zip_code %></value>
    </field>
    <field name="date_of_birth">
      <value><%= pdf_date_of_birth %></value>
    </field>
    <field name="phone_number">
      <value><%= phone %></value>
    </field>
    <field name="id_number">
      <value><%= state_id_number %></value>
    </field>
    <field name="party">
      <value><%= party %></value>
    </field>
    <field name="race">
      <value><%= pdf_race %></value>
    </field>
    <field name="previous_name.title">
      <value><%= prev_name_title %></value>
    </field>
    <field name="previous_name.first">
      <value><%= prev_first_name %></value>
    </field>
    <field name="previous_name.middle">
      <value><%= prev_middle_name %></value>
    </field>
    <field name="previous_name.last">
      <value><%= prev_last_name %></value>
    </field>
    <field name="previous_name.suffix">
      <value><%= prev_name_suffix %></value>
    </field>
    <field name="previous_address.street">
      <value><%= prev_address %></value>
    </field>
    <field name="previous_address.unit">
      <value><%= prev_unit %></value>
    </field>
    <field name="previous_address.city">
      <value><%= prev_city %></value>
    </field>
    <field name="previous_address.state">
      <value><%= prev_state_abbrev %></value>
    </field>
    <field name="previous_address.zip_code">
      <value><%= prev_zip_code %></value>
    </field>
    <field name="uidbarcode">
      <value><%= pdf_barcode %></value>
    </field>
  </fields>
</xfdf>
XML
end