require File.dirname(__FILE__) + "/../spec_helper"
require 'hpricot'

describe ApplicationHelper do
  describe "partner_locale_options" do
    it "shows partner and locale" do
      opts = helper.partner_locale_options(2, "es")
      assert_equal 2, opts[:partner]
      assert_equal "es", opts[:locale]
    end

    it "shows partner but not default locale" do
      opts = helper.partner_locale_options(2, "en")
      assert_equal 2, opts[:partner]
      assert_nil opts[:locale]
    end

    it "shows locale but not default partner" do
      opts = helper.partner_locale_options(1, "es")
      assert_nil opts[:partner]
      assert_equal "es", opts[:locale]
    end

    it "shows neither default partner nor default locale" do
      opts = helper.partner_locale_options(1, "en")
      assert_nil opts[:partner]
      assert_nil opts[:locale]
    end
  end

  describe "rtv_partner_url" do
    it "url escapes the query params" do
      partner = Partner.new(:id => Partner.default_id)
      url = helper.rtv_partner_url(partner)
      assert_no_match %r{ }, url
    end

    it "omits partner when default" do
      partner = Partner.new
      partner.id = Partner.default_id
      url = helper.rtv_partner_url(partner)
      assert_no_match %r{%3Fpartner%3D}, url
    end

    it "includes partner param when not default" do
      partner = Partner.new
      partner.id = Partner.default_id + 1
      url = helper.rtv_partner_url(partner)
      assert_match %r{%3Fpartner%3D}, url
    end
  end
end
