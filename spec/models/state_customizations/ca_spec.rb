require 'spec_helper'

describe CA do
  let(:ca) { CA.new(GeoState['CA']) }
  before(:each) do
    Integrations::Soap.stub(:make_request).and_return("stubbed response")
    RockyConf.ovr_states.CA.api_settings.stub(:debug_in_ui).and_return(true)
    
  end
  describe "has_ovr_pre_check?" do
    subject { ca.has_ovr_pre_check?(nil) }
    it { should be_true }
  end
  
  describe "self.build_soap_xml(registrant)" do
    let(:reg) { FactoryGirl.build(:step_3_registrant) }
    it "populates the maximal registrant template with registrant values" do
      CA.build_soap_xml(reg).should == fixture_file_contents("covr/max_registrant.xml")
    end
  end
  
  describe "self.request_token" do
    
  end
  
  describe "ovr_pre_check" do
    let(:reg) { mock_model(Registrant) }
    let(:con) { mock(Step3Controller) }
    before(:each) do
      CA.stub(:build_soap_xml).with(reg).and_return("XML")
      CA.stub(:request_token).with("XML").and_return("stubbed response")
      con.stub(:render)
    end
    it "builds XML" do
      CA.should_receive(:build_soap_xml).with(reg).and_return("XML")
      ca.ovr_pre_check(reg, con)
    end
    it "makes an API call" do
      CA.should_receive(:request_token).with("XML")
      ca.ovr_pre_check(reg, con)
    end
    context "when debugging" do
      it "rendes the API response" do
        con.should_receive(:render).with(:xml=>"stubbed response", :layout=>nil, :content_type=>"application/xml")
        ca.ovr_pre_check(reg, con)
      end
    end
  end
end
