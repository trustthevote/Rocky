require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Notifier do
  attr_reader :email, :partner
  before do
    @partner = Factory.create(:partner)

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  describe "#password_reset_instruction" do
    before do
      Notifier.deliver_password_reset_instructions(partner)
      ActionMailer::Base.deliveries.size.should == 1
      @email = ActionMailer::Base.deliveries.first
    end

    it "delivers the expected email" do
      email.body.should =~ /A request to reset your password has been made/i
      email.body.should include(partner.perishable_token)
    end
  end
end
