require File.dirname(__FILE__) + '/../spec_helper'

describe Mergable do
  before(:each) do
    @registrant = Factory.build(:maximal_registrant)
    @doc = Nokogiri::XML(@registrant.to_xfdf)
  end
  it "should output us citizen" do
    assert_equal  @registrant.us_citizen? ? 'Yes' : 'No',
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DropDownList2[0]"] value').text
  end
  it "should output will be 18" do
    assert_equal  @registrant.will_be_18_by_election? ? 'Yes' : 'No',
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DropDownList2[1]"] value').text
  end

  it "should output name title" do
    assert_equal  @registrant.name_title,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DropDownList1[0]"] value').text
  end
  it "should output first name" do
    assert_equal  @registrant.first_name,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField1[1]"] value').text
  end
  it "should output middle name" do
    assert_equal  @registrant.middle_name,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField1[0]"] value').text
  end
  it "should output last name" do
    assert_equal  @registrant.last_name,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField1[2]"] value').text
  end
  it "should output name suffix" do
    assert_equal  @registrant.name_suffix,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DropDownList1[1]"] value').text
  end

  it "should output home address street" do
    assert_equal  @registrant.home_address,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField2[0]"] value').text
  end
  it "should output home address unit" do
    assert_equal  @registrant.home_unit,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField3[0]"] value').text
  end
  it "should output home address city" do
    assert_equal  @registrant.home_city,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField4[0]"] value').text
  end
  it "should output home address state" do
    assert_equal  @registrant.home_state.abbreviation,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField5[0]"] value').text
  end
  it "should output home address zip code" do
    assert_equal  @registrant.home_zip_code,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField6[0]"] value').text
  end

  it "should output mailing address street" do
    assert_equal  "#{@registrant.mailing_address} #{@registrant.mailing_unit}",
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField7[0]"] value').text
  end
  it "should output mailing address city" do
    assert_equal  @registrant.mailing_city,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField8[0]"] value').text
  end
  it "should output mailing address state" do
    assert_equal  @registrant.mailing_state.abbreviation,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField9[0]"] value').text
  end
  it "should output mailing address zip code" do
    assert_equal  @registrant.mailing_zip_code,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField10[0]"] value').text
  end

  it "should output date of birth" do
    assert_equal  @registrant.pdf_date_of_birth,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DateTimeField1[0]"] value').text
  end
  it "should output phone" do
    assert_equal  @registrant.phone,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].NumericField1[0]"] value').text
  end
  it "should output state ID number" do
    assert_equal  @registrant.state_id_number,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField11[0]"] value').text
  end
  it "should output party" do
    assert_equal  @registrant.party,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField22[0]"] value').text
  end
  it "should output race" do
    assert_equal  @registrant.race,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField23[0]"] value').text
  end

  it "should output previous name title" do
    assert_equal  @registrant.prev_name_title,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DropDownList1[2]"] value').text
  end
  it "should output previous first name" do
    assert_equal  @registrant.prev_first_name,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField13[0]"] value').text
  end
  it "should output previous middle name" do
    assert_equal  @registrant.prev_middle_name,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField14[0]"] value').text
  end
  it "should output previous last name" do
    assert_equal  @registrant.prev_last_name,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField12[0]"] value').text
  end
  it "should output previous name suffix" do
    assert_equal  @registrant.prev_name_suffix,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].DropDownList1[3]"] value').text
  end

  it "should output previous address street" do
    assert_equal  @registrant.prev_address,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField15[0]"] value').text
  end
  it "should output previous address unit" do
    assert_equal  @registrant.prev_unit,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField16[0]"] value').text
  end
  it "should output previous address city" do
    assert_equal  @registrant.prev_city,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField17[0]"] value').text
  end
  it "should output previous address state" do
    assert_equal  @registrant.prev_state.abbreviation,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField18[0]"] value').text
  end
  it "should output previous address zip code" do
    assert_equal  @registrant.prev_zip_code,
                  @doc.css('xfdf fields field[name="topmostSubform[0].Page4[0].TextField19[0]"] value').text
  end
end
