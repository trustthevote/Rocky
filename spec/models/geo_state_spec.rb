require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GeoState do
  it "should cache by state abbreviation" do
    assert_equal(GeoState['CA'].object_id, GeoState['CA'].object_id)
  end

  it "constructs array of name/abbrev tuples in alphabetical order" do
    states = GeoState.collection_for_select
    assert_equal 51, states.size
    names, abbrevs = states.transpose
    assert_equal %w(Alabama Alaska Arizona Arkansas California), names[0..4]
    assert_equal %w(AL AK AZ AR CA), abbrevs[0..4]
  end
  
  describe "in current locale" do
    before(:all) do
      @old_locale = I18n.locale
    end

    after(:all) do
      I18n.locale = @old_locale
    end

    it "finds parties for current locale" do
      I18n.locale = :en
      assert_equal "Democratic", GeoState['CA'].parties.first
      I18n.locale = :es
      assert_equal "Demócrata", GeoState['CA'].parties.first
    end
  end
end
