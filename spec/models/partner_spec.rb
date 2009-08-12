require File.dirname(__FILE__) + '/../spec_helper'

describe Partner do
  describe "#primary?" do
    it "is true for primary partner" do
      assert Partner.find(Partner.default_id).primary?
    end
    
    it "is false for non-primary partner" do
      assert !Factory.build(:partner).primary?
    end
  end
  
  describe "#logo_image_url" do
    it "is saved for non-primary partner" do
      url = "http://example.com/logo.jpg"
      assert_equal url, Factory.create(:partner, :logo_image_url => url).logo_image_url
    end
    it "is local for primary partner" do
      assert_match /^reg/, Partner.find(Partner.default_id).logo_image_url
    end
  end
end
