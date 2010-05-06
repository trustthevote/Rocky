require File.dirname(__FILE__) + '/../spec_helper'

describe StateRegistrationSite do
  describe "transfer voter registration to state site" do
    it "short-circuits when not transferable" do
      reg = Factory.create(:step_3_registrant, :home_zip_code => "15215", :party => "Republican")
      site = StateRegistrationSite.new(reg)
      assert_nil site.transfer
    end

    if ENV['INTEGRATE_COLORADO']
      puts "(Running external integration tests for Colorado reg site)"
      describe "external integration" do
        it "returns the redirect location" do
          reg = Factory.create(:step_3_registrant, :home_zip_code => "80202", :party => "Republican")
          # keep sensitive personal test info in memory only, not in DB or test log
          reg.attributes = YAML.load_file("reg_colorado.yml")[:real]
          assert reg.valid?
          site = StateRegistrationSite.new(reg)
          assert_match %r{/Voter/editVoterDetails\.do}, site.transfer
        end

        it "returns nil when registrant not a valid voter" do
          # "1111" is not valid CO drivers license number
          reg = Factory.create(:step_3_registrant, :home_zip_code => "80202", :party => "Republican", :state_id_number => "1111")
          site = StateRegistrationSite.new(reg)
          assert_nil site.transfer
        end
      end
    end
  end
end
