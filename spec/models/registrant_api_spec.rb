require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Registrant do

  describe 'build_from_api_data' do
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

    context 'validating opt_in_xyz' do
      specify { registrant_opt_in_xyz(nil, true) }
      specify { registrant_opt_in_xyz(0, false) }
      specify { registrant_opt_in_xyz(1, false) }
      specify { registrant_opt_in_xyz('1', false) }
      specify { registrant_opt_in_xyz(true, false) }
      specify { registrant_opt_in_xyz(false, false) }
    end

    it 'should not require a party' do
      r = Registrant.build_from_api_data({})
      r.stub(:requires_party?) { true }
      r.valid?

      r.should have(0).errors_on(:party)
    end

    it 'should not require the first name' do
      r = build_and_validate
      r.should have(0).errors_on(:first_name)
    end
    
    it 'should not require has_state_license' do
      r = Registrant.build_from_api_data(:has_state_license=>nil)
      r.stub(:at_least_step_2?) { true }
      r.valid?
      r.should have(0).errors_on(:has_state_license)
    end
    
    it "sets the finish_with_state_flag if passed in as true" do
      r = Registrant.build_from_api_data(:email_address=>"test@example.com")
      r.finish_with_state.should be_falsey
       
      r = Registrant.build_from_api_data({:email_address=>"test@example.com"}, false)
      r.finish_with_state.should be_falsey
      
      r = Registrant.build_from_api_data({:email_address=>"test@example.com"}, true)
      r.finish_with_state.should be_truthy
    end
    
    it 'should require send_confirmation_reminder_emails if finish_with_state is true' do
      r = Registrant.build_from_api_data({:send_confirmation_reminder_emails=>nil}, true)
      r.valid?
      r.should have(1).error_on(:send_confirmation_reminder_emails)
    end
    
  
  end



  describe "#enqueue_complete_registration_via_api" do
    it "should queue up complete_registration_via_api" do
      reg = Registrant.new
      reg.stub(:complete_registration_via_api)
      reg.should_receive(:complete_registration_via_api)
      reg.enqueue_complete_registration_via_api
    end
  end
  
  
  describe "#complete_registration_via_api" do
    let(:reg)  { Registrant.new(:send_confirmation_reminder_emails=>true) }
    before(:each) do
      reg.stub(:save)
      reg.stub(:generate_pdf)
      reg.stub(:queue_pdf)
      reg.stub(:redact_sensitive_data)
      reg.stub(:deliver_confirmation_email)
      reg.stub(:enqueue_reminder_emails)
      reg.stub(:finalize_pdf)
    end
    

    
    context "when finish_with_state is false" do
      it "queues pdf, sets status to complete and saves" do
        reg.should_receive(:queue_pdf)
        reg.should_receive(:save)

        reg.should_not_receive(:generate_pdf)        
        reg.should_not_receive(:redact_sensitive_data)        
        reg.should_not_receive(:deliver_confirmation_email)        
        reg.should_not_receive(:enqueue_reminder_emails)        

        reg.complete_registration_via_api
        reg.status.should == 'complete'

      end      
      
    end
    
    
    context 'when async is false' do
      it "should not queue PDF" do
        reg.should_not_receive(:queue_pdf)
        reg.complete_registration_via_api(false)
      end
      it "should generate PDF" do
        reg.should_receive(:generate_pdf)
        reg.complete_registration_via_api(false)
      end
      it "should finalize PDF" do
        reg.should_receive(:finalize_pdf)
        reg.complete_registration_via_api(false)
      end
    end
  end

  private

  def build_and_validate(data = {})
    r = Registrant.build_from_api_data(data)
    r.valid?
    r
  end

  def registrant_citizen(us_citizen, error)
    r = build_and_validate :us_citizen => us_citizen
    r.should have(error ? 1 : 0).errors_on(:us_citizen)
    if error
      r.errors_on(:us_citizen).should include("Required value is '1' or 'true'")
    end
  end

  def registrant_email_address(addr, error)
    r = build_and_validate :email_address => addr
    r.should have(error ? 1 : 0).errors_on(:email_address)
  end

  def registrant_opt_in_xyz(v, error)
    r = build_and_validate :opt_in_sms => v, :opt_in_email => v
    r.should have(error ? 1 : 0).error_on(:opt_in_sms)
    r.should have(error ? 1 : 0).error_on(:opt_in_email)
  end

end
