require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Notifier do
  attr_reader :email

  describe "#password_reset_instruction" do
    it "delivers the expected email" do
      partner = Factory.create(:partner)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_password_reset_instructions(partner)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /A request to reset your password has been made/i
      email.body.should include(partner.perishable_token)
    end
  end

  describe "#confirmation" do
    it "delivers the expected email" do
      registrant = Factory.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_confirmation(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http")
      email.body.should include(registrant.pdf_path)
    end
  end

  describe "#reminder" do
    it "delivers the expected email" do
      registrant = Factory.create(:maximal_registrant, :reminders_left  => 1)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_reminder(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http")
      email.body.should include(registrant.pdf_path)
    end

    it "delivers the expected email in a different locale" do
      registrant = Factory.create(:maximal_registrant, :locale => 'es')
      Notifier.deliver_reminder(registrant)
      email = ActionMailer::Base.deliveries.last
      email.subject.should include(I18n.t("email.reminder.subject", :locale => :es))
    end
  end
end
