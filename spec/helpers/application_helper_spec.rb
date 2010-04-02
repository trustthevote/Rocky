require File.dirname(__FILE__) + "/../spec_helper"
require 'hpricot'

describe ApplicationHelper do
  describe "partner_locale_options" do
    it "shows partner, locale and source" do
      opts = helper.partner_locale_options(2, "es", "email")
      assert_equal 2, opts[:partner]
      assert_equal "es", opts[:locale]
      assert_equal "email", opts[:source]
    end

    it "shows partner but not default locale" do
      opts = helper.partner_locale_options(2, "en", nil)
      assert_equal 2, opts[:partner]
      assert_nil opts[:locale]
    end

    it "shows locale but not default partner" do
      opts = helper.partner_locale_options(1, "es", nil)
      assert_nil opts[:partner]
      assert_equal "es", opts[:locale]
    end

    it "shows neither default partner nor default locale" do
      opts = helper.partner_locale_options(1, "en", nil)
      assert_nil opts[:partner]
      assert_nil opts[:locale]
    end

    it "omits blank source" do
      opts = helper.partner_locale_options(2, "es", nil)
      assert !opts.has_key?(:source)
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

  describe "form helpers" do
    attr_accessor :form
    before(:each) do
      @form = Object.new
      partner = Partner.new
      stub(form).object { partner }
      stub(form).text_field { '<input type="text">' }
      stub(form).password_field { '<input type="password">' }
    end

    it "makes a text field by default" do
      html = helper.field_div(form, :name)
      assert_match /input type="text"/, html
    end

    it "uses :kind option to make a different type of field" do
      html = helper.field_div(form, :name, :kind => "password")
      assert_match /input type="password"/, html
    end
  end
end
