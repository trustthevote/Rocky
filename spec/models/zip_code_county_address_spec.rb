require 'spec_helper'

describe ZipCodeCountyAddress do
  
  it { should validate_uniqueness_of(:zip) }
  it { should validate_presence_of(:zip) }
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:geo_state_id) }
end
