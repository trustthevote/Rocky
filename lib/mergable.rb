module Mergable
  def to_xfdf
    ERB.new(XFDF_TEMPLATE).result(binding)
  end

  XFDF_TEMPLATE = <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
  <f href=""/>
  <ids original="" modified=""/>
  <fields>
    <field name="topmostSubform[0].Page4[0].DropDownList2[0]">
      <value><%= us_citizen? ? 'Yes' : 'No' %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].DropDownList2[1]">
      <value><%= will_be_18_by_election? ? 'Yes' : 'No' %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].DropDownList1[0]">
      <value><%= name_title %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField1[1]">
      <value><%= first_name %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField1[0]">
      <value><%= middle_name %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField1[2]">
      <value><%= last_name %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].DropDownList1[1]">
      <value><%= name_suffix %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField2[0]">
      <value><%= home_address %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField3[0]">
      <value><%= home_unit %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField4[0]">
      <value><%= home_city %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField5[0]">
      <value><%= home_state.abbreviation %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField6[0]">
      <value><%= home_zip_code %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField7[0]">
      <value><%= mailing_address %> <%= mailing_unit %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField8[0]">
      <value><%= mailing_city %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField9[0]">
      <value><%= mailing_state_abbrev %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField10[0]">
      <value><%= mailing_zip_code %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].DateTimeField1[0]">
      <value><%= pdf_date_of_birth %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].NumericField1[0]">
      <value><%= phone %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField11[0]">
      <value><%= state_id_number %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField22[0]">
      <value><%= party %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField23[0]">
      <value><%= race %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].DropDownList1[2]">
      <value><%= prev_name_title %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField13[0]">
      <value><%= prev_first_name %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField14[0]">
      <value><%= prev_middle_name %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField12[0]">
      <value><%= prev_last_name %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].DropDownList1[3]">
      <value><%= prev_name_suffix %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField15[0]">
      <value><%= prev_address %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField16[0]">
      <value><%= prev_unit %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField17[0]">
      <value><%= prev_city %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField18[0]">
      <value><%= prev_state_abbrev %></value>
    </field>
    <field name="topmostSubform[0].Page4[0].TextField19[0]">
      <value><%= prev_zip_code %></value>
    </field>
  </fields>
</xfdf>
XML
end