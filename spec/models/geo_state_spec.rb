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
end
