require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
      stub(r).requires_party? { true }
      r.valid?

      r.should have(0).errors_on(:party)
    end

    it 'should not require the first name' do
      r = build_and_validate
      r.should have(0).errors_on(:first_name)
    end
    
    it 'should not require has_state_license' do
      r = Registrant.build_from_api_data(:has_state_license=>nil)
      stub(r).at_least_step_2? { true }
      stub(r).custom_step_2? { true }
      r.valid?
      r.should have(0).errors_on(:has_state_license)
    end
    
    it "sets the finish_with_state_flag if passed in as true" do
      r = Registrant.build_from_api_data(:email_address=>"test@example.com")
      r.finish_with_state.should be_false
       
      r = Registrant.build_from_api_data({:email_address=>"test@example.com"}, false)
      r.finish_with_state.should be_false
      
      r = Registrant.build_from_api_data({:email_address=>"test@example.com"}, true)
      r.finish_with_state.should be_true
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

      mock(Time).now {"now"}
      mock(Delayed::PerformableMethod).new(reg,:complete_registration_via_api,[]) { "Action" }
      mock(Delayed::Job).enqueue("Action", Registrant::WRAP_UP_PRIORITY, "now")
      
      reg.enqueue_complete_registration_via_api
    end
  end
  
  describe "#complete_registration_via_api" do
    context "when send_confirmation_reminder_emails is true" do
      it "generates pdf, redacts sensitif data, sets the status to complete, deliver_confirmation_email, enqueue_reminder_emails and saves" do
        reg = Registrant.new(:send_confirmation_reminder_emails=>true)
        mock(reg).generate_pdf
        mock(reg).redact_sensitive_data
        mock(reg).deliver_confirmation_email
        mock(reg).enqueue_reminder_emails
        mock(reg).save
        
        
        reg.complete_registration_via_api
        reg.status.should == 'complete'
        reg.should have_received(:generate_pdf)        
        reg.should have_received(:redact_sensitive_data)        
        reg.should have_received(:deliver_confirmation_email)        
        reg.should have_received(:enqueue_reminder_emails)        
        reg.should have_received(:save)        
      end
    end
    context "when send_confirmation_reminder_emails is false" do
      it "generates pdf, redacts sensitif data, sets the status to complete and saves" do
        reg = Registrant.new(:send_confirmation_reminder_emails=>false)
        mock(reg).generate_pdf
        mock(reg).redact_sensitive_data
        mock(reg).save
        
        reg.complete_registration_via_api
        
        reg.status.should == 'complete'
        reg.should_not have_received(:deliver_confirmation_email)
        reg.should_not have_received(:enqueue_reminder_emails)        
        
        reg.should have_received(:generate_pdf)        
        reg.should have_received(:redact_sensitive_data)        
        reg.should have_received(:save)        
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
