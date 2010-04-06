require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionView::Helpers::UrlHelper

describe FinishesController do
  integrate_views

  describe "complete registration" do
    before(:each) do
      @registrant = Factory.create(:completed_registrant)
    end

    it "sets default content for message body" do
      get :show, :registrant_id => @registrant.to_param
      assert_match %r(Hey, I just registered to vote), assigns[:registrant].tell_message
      assert_match Regexp.compile(Regexp.escape(root_url(:source => "email"))), assigns[:registrant].tell_message
    end

    it "shows share links and tell-a-friend email form" do
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "finish"

      assert_select "h1", "Spread the word!"

      assert_share_links "I just registered to vote and you can too!"

      assert_select "form div.button a.button_sendemail_en"
    end
  end

  describe "under 18" do
    before(:each) do
      @registrant = Factory.create(:under_18_finished_registrant)
    end

    it "sets default content for message body" do
      get :show, :registrant_id => @registrant.to_param
      assert_match %r(Are you registered to vote\?  I may not be old enough to vote), assigns[:registrant].tell_message
      assert_match Regexp.compile(Regexp.escape(root_url(:source => "email"))), assigns[:registrant].tell_message
    end

    it "shows share links and tell-a-friend email form" do
      get :show, :registrant_id => @registrant.to_param

      assert_select "h1", "You're on the list!"

      assert_share_links "Make sure you register to vote. It's easy!"

      assert_select "form div.button a.button_sendemail_en"
    end
  end

  def assert_share_links(share_text)
    assert_select "div.share div", 3

    assert_select "a[class=button_share_facebook_en][href=http://www.facebook.com/sharer.php?u=http%3A%2F%2Fwww.rockthevote.com%2Fregister%2Ffb&t=#{CGI.escape(share_text)}]"

    escaped = CGI.escape(share_text + " " + root_url)
    href = "http://twitter.com/home"
    href << "?status=#{escaped}"
    assert_select "a[class=button_share_twitter_en][href=#{href}]"

    href = "http://www.google.com/reader/link"
    href << "?url=#{CGI.escape(root_url)}"
    href << "&amp;srcURL=#{CGI.escape(root_url)}"
    href << "&amp;srcTitle=Rock%20the%20Vote"
    href << "&amp;title=#{CGI.escape(share_text)}"
    assert_select "a[class=button_share_googlebuzz_en][href=#{href}]"
  end
end
