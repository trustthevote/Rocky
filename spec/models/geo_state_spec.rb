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

  describe "zip code" do
    before(:each) do
      # set up test mapping data
    end

    it "returns nil for bad zip codes" do
      assert_nil GeoState.for_zip_code("00000")
    end

    it "finds the state for a given zip code prefix" do
      assert_equal GeoState["CA"], GeoState.for_zip_code("90001")
      assert_equal GeoState["CA"], GeoState.for_zip_code("94110")
      assert_equal GeoState["CA"], GeoState.for_zip_code("96110")
    end

    it "gives precedence to 5 digit exceptions" do
      assert_equal GeoState["CT"], GeoState.for_zip_code("06301")
      assert_equal GeoState["NY"], GeoState.for_zip_code("06390") # exception
      assert_equal GeoState["CT"], GeoState.for_zip_code("06391")
    end

    it "maps all our 3 digit prefixes to valid states" do
      assert GeoState.zip3map.keys.all? {|zip| GeoState.for_zip_code(zip) }
    end
  end
end
