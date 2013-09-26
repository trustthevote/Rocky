require 'spec_helper'

describe NV do
  let(:root_url) { "https://nvsos.gov/sosvoterservices/Registration/step1.aspx?source=rtv&utm_source=rtv&utm_medium=rtv&utm_campaign=rtv" }
  it "should inherit from StateCustomization" do
    NV.superclass.should == StateCustomization
  end
  
  describe "online_reg_url(registrant)" do
    let(:nv) { NV.new(GeoState['NV']) }
    let(:reg) { mock(Registrant) }
    context "when registrant is nil" do
      it "returns the root URL" do
        nv.online_reg_url(nil).should == root_url
      end
    end
    context "when registrant is not nill" do
      before(:each) do
        reg.stub(:first_name).and_return("First Name")
        reg.stub(:middle_name).and_return("Middle Name")
        reg.stub(:last_name).and_return("Last Name")
        reg.stub(:home_zip_code).and_return("12345")
        reg.stub(:name_suffix).and_return("mr.")        
        reg.stub(:locale).and_return('aa')
      end
      it "includes an escaped registrant first, middle, last, suffix, zip and locale" do
        nv.online_reg_url(reg).should ==
          "#{root_url}&fn=First+Name&mn=Middle+Name&ln=Last+Name&lang=aa&zip=12345&sf=mr."
      end
    end
  end
end
