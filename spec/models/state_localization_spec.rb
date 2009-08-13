require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StateLocalization do
  describe "tooltips" do
    it "should accomodate long tooltips" do
      kilo_chars = "s" * 1024
      loc = StateLocalization.create!(
        :locale => 'en',
        :not_participating_tooltip => kilo_chars,
        :race_tooltip => kilo_chars,
        :id_number_tooltip => kilo_chars)

      loc.reload
      assert_equal kilo_chars, loc.not_participating_tooltip
      assert_equal kilo_chars, loc.race_tooltip
      assert_equal kilo_chars, loc.id_number_tooltip
    end
  end
end
