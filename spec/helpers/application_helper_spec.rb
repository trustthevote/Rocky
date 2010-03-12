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
end