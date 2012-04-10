require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Registrant do

  describe 'build_from_api_data' do
    context 'passing attributes' do
      before  { @r = Registrant.build_from_api_data({ :first_name => 'Jack' }) }
      specify { @r.first_name.should == 'Jack' }
      specify { @r.status.should == Registrant::STEPS.last.to_s }
      specify { @r.should_not be_valid }
    end

    context 'validating us_citizen' do
      specify { registrant_citizen(1, false) }
      specify { registrant_citizen('1', false) }
      specify { registrant_citizen(true, false) }
      specify { registrant_citizen(nil, true) }
      specify { registrant_citizen(0, true) }
      specify { registrant_citizen(false, true) }
    end

    context 'validating email_address' do
      specify { registrant_email_address('alex@smith.com', false) }
      specify { registrant_email_address('alex+2@smith.com', false) }
      specify { registrant_email_address('invalid', true) }
    end

    it 'should validate presence of opt_in_xyz' do
      r = Registrant.build_from_api_data({})
      r.valid?
      r.should have(1).error_on(:opt_in_sms)
      r.should have(1).error_on(:opt_in_email)
    end
  end

  private

  def registrant_citizen(us_citizen, error)
    r = Registrant.build_from_api_data({ :us_citizen => us_citizen })
    r.valid?
    r.should have(error ? 1 : 0).errors_on(:us_citizen)
  end

  def registrant_email_address(addr, error)
    r = Registrant.build_from_api_data({ :email_address => addr })
    r.valid?
    r.should have(error ? 1 : 0).errors_on(:email_address)
  end
end
