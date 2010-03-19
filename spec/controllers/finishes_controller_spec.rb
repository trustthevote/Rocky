require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionView::Helpers::UrlHelper

describe FinishesController do
  integrate_views

  describe "complete registration" do
    before(:each) do
      @registrant = Factory.create(:completed_registrant)
    end

    it "shows share links and tell-a-friend email form" do
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "finish"
      # rtv_partner_url = "https%3A%2F%2Fregister.rockthevote.com%2Fregistrants%2Fnew%3Fpartner%3D#{@registrant.partner.id}"

      assert_select "h1", "Spread the word!"

      assert_select "div.share div", 3

      assert_select "a[class=button_share_facebook_en][href=http://www.facebook.com/sharer.php?u=http%3A%2F%2Fwww.rockthevote.com%2Fregister%2Ffb]"

      escaped = "I%20just%20registered%20to%20vote%20and%20you%20can%20too%21%20" + root_url
      href = "http://twitter.com/home"
      href << "?status=#{escaped}"
      assert_select "a[class=button_share_twitter_en][href=#{href}]"

      href = "http://www.google.com/reader/link"
      href << "?url=#{root_url}"
      href << "&amp;srcURL=#{root_url}"
      href << "&amp;srcTitle=Rock%20the%20Vote"
      href << "&amp;title=I%20just%20registered%20to%20vote%20and%20you%20can%20too%21"
      assert_select "a[class=button_share_googlebuzz_en][href=#{href}]"

      assert_select "form div.button a.button_sendemail_en"
    end
  end

  describe "under 18" do
    before(:each) do
      @registrant = Factory.create(:under_18_finished_registrant)
    end

    it "shows share links and tell-a-friend email form" do
      get :show, :registrant_id => @registrant.to_param

      assert_select "h1", "You're on the list!"

      assert_select "div.share div", 3

      assert_select "a[class=button_share_facebook_en][href=http://www.facebook.com/sharer.php?u=http%3A%2F%2Fwww.rockthevote.com%2Fregister%2Ffb]"

      escaped = "I%20just%20registered%20to%20vote%20and%20you%20can%20too%21%20" + root_url
      href = "http://twitter.com/home"
      href << "?status=#{escaped}"
      assert_select "a[class=button_share_twitter_en][href=#{href}]"

      href = "http://www.google.com/reader/link"
      href << "?url=#{root_url}"
      href << "&amp;srcURL=#{root_url}"
      href << "&amp;srcTitle=Rock%20the%20Vote"
      href << "&amp;title=I%20just%20registered%20to%20vote%20and%20you%20can%20too%21"
      assert_select "a[class=button_share_googlebuzz_en][href=#{href}]"

      assert_select "form div.button a.button_sendemail_en"
    end
  end
end
