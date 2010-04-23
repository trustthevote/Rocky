require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RemindersController do

  it "stops remaining emails from coming" do
    reg = Factory.create(:completed_registrant, :reminders_left => 2)
    get :show, :registrant_id => reg.to_param
    reg.reload
    assert_equal 0, reg.reminders_left
  end

  describe "feedback page" do
    integrate_views
    it "should show progress as complete" do
      reg = Factory.create(:completed_registrant, :reminders_left => 2)
      get :show, :registrant_id => reg.to_param
      assert_select "li.progress-done", 5
    end
  end
end
