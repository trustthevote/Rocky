require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registrant do
  describe "step 1" do
    it "should require personal info" do
      assert_attribute_invalid_with(:step_1_registrant, :email_address => nil)
      assert_attribute_invalid_with(:step_1_registrant, :home_zip_code => nil)
      assert_attribute_invalid_with(:step_1_registrant, :date_of_birth => nil)
      assert_attribute_invalid_with(:step_1_registrant, :us_citizen => false)
    end
    
    it "should not require contact information" do
      assert_attribute_valid_with(:step_1_registrant, :name_title => nil)
      assert_attribute_valid_with(:step_1_registrant, :first_name => nil)
      assert_attribute_valid_with(:step_1_registrant, :last_name => nil)
      assert_attribute_valid_with(:step_1_registrant, :home_address => nil)
      assert_attribute_valid_with(:step_1_registrant, :home_city => nil)
      assert_attribute_valid_with(:step_1_registrant, :home_state => nil)
    end
  end

  describe "step 2" do
    it "should require contact information" do
      assert_attribute_invalid_with(:step_2_registrant, :name_title => nil)
      assert_attribute_invalid_with(:step_2_registrant, :first_name => nil)
      assert_attribute_invalid_with(:step_2_registrant, :last_name => nil)
      assert_attribute_invalid_with(:step_2_registrant, :home_address => nil)
      assert_attribute_invalid_with(:step_2_registrant, :home_city => nil)
      reg = Factory.build(:step_2_registrant, :home_state_abbrev => nil)
      reg.invalid?
      assert reg.errors.on(:home_state_id)
    end

    it "should require race but only for certain states" do
      state_with = GeoState.find_by_requires_race(true)
      reg = Factory.build(:step_2_registrant, :home_state_abbrev => state_with.abbreviation, :race => nil)
      assert reg.invalid?
      assert reg.errors.on(:race)
    end

    it "should not require race for some states" do
      state_without = GeoState.find_by_requires_race(false)
      reg = Factory.build(:step_2_registrant, :home_state_abbrev => state_without.abbreviation, :race => nil)
      assert reg.valid?
    end

    it "should only update mailing address attributes if :has_mailing_address is set" do
      reg = Factory.create(:step_2_registrant, :mailing_state_abbrev => "PA", :has_mailing_address => "0")
      assert_nil reg.mailing_state
    end
  end

  describe "states by abbreviation" do
    it "sets state by abbreviation" do
      new_york = GeoState['NY']
      reg = Factory.create(:step_1_registrant, :home_state_abbrev => "NY",
                                               :mailing_state_abbrev => "NY", :has_mailing_address => "1",
                                               :prev_state_abbrev => "NY")
      assert_equal new_york.id, reg.home_state_id
      assert_equal new_york.id, reg.mailing_state_id
      assert_equal new_york.id, reg.prev_state_id
    end

    it "gets abbrev for state" do
      new_york = GeoState['NY']
      reg = Factory.create(:step_1_registrant, :home_state => new_york,
                                               :mailing_state => new_york, :has_mailing_address => "1",
                                               :prev_state => new_york)
      assert_equal new_york.abbreviation, reg.home_state_abbrev
      assert_equal new_york.abbreviation, reg.mailing_state_abbrev
      assert_equal new_york.abbreviation, reg.prev_state_abbrev
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
