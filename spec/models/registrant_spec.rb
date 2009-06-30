require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registrant do
  it "should require first name" do
    reg = Factory.build(:registrant, :first_name => nil)
    assert reg.invalid?
    assert reg.errors.on(:first_name)
  end
end
