require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TellFriendsController do
  describe "#create" do
    before(:each) do
      @registrant = Factory.create(:step_5_registrant)
    end

    it "should enqueue sending tell-a-friend email" do
      tell_params = {
        :tell_from => "Bob Dobbs",
        :tell_email => "bob@example.com",
        :tell_recipients => "arnold@example.com, obo@example.com",
        :tell_subject => "Register to vote the easy way",
        :tell_message => "I registered to vote and you can too."
      }

      assert_difference "Delayed::Job.count" do
        post :create, :registrant_id => @registrant.to_param, :tell_friend => tell_params
      end
      assert_not_nil assigns[:registrant]
      assert assigns[:email_sent]

      assert :success
      assert_template "finishes/show"
    end

    it "should show form again when fields are missing" do
      tell_params = {
        :tell_from => "Bob Dobbs",
        :tell_email => "",
        :tell_recipients => "",
        :tell_subject => "Register to vote the easy way",
        :tell_message => "I registered to vote and you can too."
      }

      assert_difference "Delayed::Job.count", 0 do
        post :create, :registrant_id => @registrant.to_param, :tell_friend => tell_params
      end
      assert_not_nil assigns[:registrant]
      assert !assigns[:email_sent]

      assert :success
      assert_template "finishes/show"
    end
  end
end
