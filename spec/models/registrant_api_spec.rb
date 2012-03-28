require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registrant do

  describe 'build_from_api_data' do
    before  { @r = Registrant.build_from_api_data({ :first_name => 'Jack' }) }

    specify { @r.first_name.should == 'Jack' }
    specify { @r.status.should == Registrant::STEPS.last.to_s }
    specify { @r.should_not be_valid }
  end

end
