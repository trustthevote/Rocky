require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registrant do
  describe "step 1" do
    it "should require personal info" do
      assert_attribute_invalid_with(:step_1_registrant, :partner_id => nil)
      assert_attribute_invalid_with(:step_1_registrant, :locale => nil)
      assert_attribute_invalid_with(:step_1_registrant, :email_address => nil)
      assert_attribute_invalid_with(:step_1_registrant, :home_zip_code => nil, :home_state_id => nil)
      assert_attribute_invalid_with(:step_1_registrant, :date_of_birth => nil)
      assert_attribute_invalid_with(:step_1_registrant, :us_citizen => false)
    end
    
    it "should not require contact information" do
      assert_attribute_valid_with(:step_1_registrant, :name_title => nil)
      assert_attribute_valid_with(:step_1_registrant, :first_name => nil)
      assert_attribute_valid_with(:step_1_registrant, :last_name => nil)
      assert_attribute_valid_with(:step_1_registrant, :home_address => nil)
      assert_attribute_valid_with(:step_1_registrant, :home_city => nil)
    end
  end

  describe "step 2" do
    it "should require contact information" do
      assert_attribute_invalid_with(:step_2_registrant, :name_title => nil)
      assert_attribute_invalid_with(:step_2_registrant, :first_name => nil)
      assert_attribute_invalid_with(:step_2_registrant, :last_name => nil)
      assert_attribute_invalid_with(:step_2_registrant, :home_address => nil)
      assert_attribute_invalid_with(:step_2_registrant, :home_city => nil)
    end

    it "should not require state id" do
      assert_attribute_valid_with(:step_2_registrant, :state_id_number => nil)
    end

    it "should require race but only for certain states" do
      reg = Factory.build(:step_2_registrant, :race => nil)
      mock(reg).requires_race? {true}
      assert reg.invalid?
      assert reg.errors.on(:race)
    end

    it "should not require race for some states" do
      reg = Factory.build(:step_2_registrant, :race => nil)
      mock(reg).requires_race? {false}
      assert reg.valid?
    end
  end

  describe "step 3" do
    it "should require state id" do
      assert_attribute_invalid_with(:step_3_registrant, :state_id_number => nil)
    end
  end


  describe "home state name" do
    it "gets name for state" do
      new_york = GeoState['NY']
      reg = Factory.build(:step_1_registrant, :home_state => new_york)
      assert_equal new_york.name, reg.home_state_name
    end
  end

  describe "states by abbreviation" do
    it "sets state by abbreviation" do
      new_york = GeoState['NY']
      reg = Factory.create(:step_1_registrant, :mailing_state_abbrev => "NY", :prev_state_abbrev => "NY")
      assert_equal new_york.id, reg.mailing_state_id
      assert_equal new_york.id, reg.prev_state_id
    end 

    it "gets abbrev for state" do
      new_york = GeoState['NY']
      reg = Factory.create(:step_1_registrant, :mailing_state => new_york, :prev_state => new_york)
      assert_equal new_york.abbreviation, reg.mailing_state_abbrev
      assert_equal new_york.abbreviation, reg.prev_state_abbrev
    end
  end

  describe "state parties" do
    it "gets parties by locale when required" do
      reg = Factory.build(:step_2_registrant, :locale => 'en', :home_state => GeoState["CA"])
      assert_equal %w(Democratic Green Libertarian Republican), reg.state_parties
      reg.locale = 'es'
      assert_equal %w(Demócrata Verde Libertariano Republicano), reg.state_parties
    end

    it "gets no parties when not required" do
      reg = Factory.build(:step_2_registrant, :home_state => GeoState["PA"])
      assert_equal nil, reg.state_parties
    end

    it "included in validations when required by state" do
      reg = Factory.build(:step_2_registrant, :party => "bogus")
      stub(reg).requires_party? { true }
      stub(reg).state_parties { %w[Democratic Republican] }
      assert reg.invalid?
      assert reg.errors.on(:party)
    end

    it "not included in validations when not required by state" do
      reg = Factory.build(:step_2_registrant, :party => nil)
      stub(reg).requires_party? { false }
      assert reg.valid?
    end
  end

  describe "PDF" do
    before(:each) do
      @registrant = Factory.create(:maximal_registrant)
    end

    it "generates PDF with merged data" do
      assert_difference('Dir[File.join(RAILS_ROOT, "public/pdf/*")].length') do
        @registrant.generate_pdf!
      end
      `rm #{@registrant.pdf_path}`
    end

    it "returns PDF if already exists" do
      `touch #{@registrant.pdf_path}`
      assert_no_difference('Dir[File.join(RAILS_ROOT, "public/pdf/*")].length') do
        @registrant.generate_pdf!
      end
      `rm #{@registrant.pdf_path}`
    end
  end

  def assert_attribute_invalid_with(model, attributes)
    reg = Factory.build(model, attributes)
    reg.invalid?
    attributes.keys.each do |attr_name|
      assert reg.errors.on(attr_name), "expected error on #{attr_name} but got none"
    end
  end

  def assert_attribute_valid_with(model, attributes)
    reg = Factory.build(model, attributes)
    assert reg.valid?
  end
end
