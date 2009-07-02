require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registrant do
  
  describe "step 1 validations" do
    it "should require personal info" do
      assert_attribute_invalid_with(:ready_for_step_1_registrant, :name_title => nil)
      assert_attribute_invalid_with(:ready_for_step_1_registrant, :first_name => nil)
      assert_attribute_invalid_with(:ready_for_step_1_registrant, :last_name => nil)
      assert_attribute_invalid_with(:ready_for_step_1_registrant, :email_address => nil)
      assert_attribute_invalid_with(:ready_for_step_1_registrant, :home_zip_code => nil)
      assert_attribute_invalid_with(:ready_for_step_1_registrant, :date_of_birth => nil)
    end
    
    it "should not require contact information" do
      assert_attribute_valid_with(:ready_for_step_1_registrant, :us_citizen => false)
      assert_attribute_valid_with(:ready_for_step_1_registrant, :home_address => nil)
      assert_attribute_valid_with(:ready_for_step_1_registrant, :home_city => nil)
      assert_attribute_valid_with(:ready_for_step_1_registrant, :home_state => nil)
    end
  end

  describe "step 2 validations" do
    it "should require contact information" do
      assert_attribute_invalid_with(:step_1_registrant, :us_citizen => false)
      assert_attribute_invalid_with(:step_1_registrant, :home_address => nil)
      assert_attribute_invalid_with(:step_1_registrant, :home_city => nil)
      assert_attribute_invalid_with(:step_1_registrant, :home_state => nil)
    end
  end

  def assert_attribute_invalid_with(model, attributes)
    reg = Factory.build(model, attributes)
    assert reg.invalid?
    attributes.keys.each do |attr_name|
      assert reg.errors.on(attr_name), "expected error on #{attr_name} but got none"
    end
  end

  def assert_attribute_valid_with(model, attributes)
    reg = Factory.build(model, attributes)
    assert reg.valid?
  end
end
