require 'spec_helper'

describe CA do
  let(:ca) { CA.new(GeoState['CA']) }
  before(:each) do
    Integrations::Soap.stub(:make_request).and_return("stubbed response")
    RockyConf.ovr_states.CA.api_settings.stub(:debug_in_ui).and_return(true)
    RockyConf.ovr_states.CA.api_settings.stub(:api_key).and_return("API_KEY")
    
  end
  describe "has_ovr_pre_check?" do
    subject { ca.has_ovr_pre_check?(nil) }
    it { should be_true }
  end
  
  describe "enabled_for_language?(lang, reg)" do
    it "returns false if 5 disclosures aren't present for the lang" do
      CA.stub(:disclosures).and_return({"en"=>{1=>1, 2=>2, 3=>3, 4=>4, 5=>5}})
      ca.enabled_for_language?("en", nil).should be_true
      CA.stub(:disclosures).and_return(nil)
      ca.enabled_for_language?("en", nil).should be_false
      CA.stub(:disclosures).and_return({"en"=>nil})
      ca.enabled_for_language?("en", nil).should be_false
      CA.stub(:disclosures).and_return({"en"=>{1=>1, 2=>2, 3=>3, 4=>4}})
      ca.enabled_for_language?("en", nil).should be_false
    end
  end
  
  describe "disclosure functions" do
    describe "self.load_disclosures" do
      it "requests the URL formated for each language and each disclosure" do
        RockyConf.ovr_states.CA.stub(:languages).and_return(["a", "b"])
        RockyConf.ovr_states.CA.languages.each do |lang|
          5.times do |i|
            num = i+1
            RestClient.should_receive(:get).with(CA.disclosure_url(lang, num)).and_return("#{lang}-#{num}")
          end
        end
        CA.load_disclosures
        CA.disclosures.should == {
          "a"=>{
            1=>"a-1",
            2=>"a-2",
            3=>"a-3",
            4=>"a-4",
            5=>"a-5"
          },
          "b"=>{
            1=>"b-1",
            2=>"b-2",
            3=>"b-3",
            4=>"b-4",
            5=>"b-5"
          }
        }
      end
    end
  
    describe "self.disclosure_url(lang, num)" do
      it "returns the configured BASE/LN/disclX.txt where LN is the 2 letter language code and X is the digit" do
        base = RockyConf.ovr_states.CA.api_settings.disclosures_url
        CA.disclosure_url("lang", 34).should == "#{base}lang/discl34.txt"
      end
    end
  end
  
  describe "self.build_soap_xml(registrant)" do
    let(:reg) { FactoryGirl.build(:maximal_registrant, :date_of_birth=>DateTime.parse("1994-03-05")) }
    it "populates the maximal registrant template with registrant values" do
      CA.build_soap_xml(reg).should == fixture_file_contents("covr/max_registrant_request.xml")
    end
  end
  
  describe "self.request_token(req_xml)" do
    it "makes a soap request with the XML at the config'd URL" do
      Integrations::Soap.should_receive(:make_request).with(RockyConf.ovr_states.CA.api_settings.api_url, "request xml")
      CA.request_token("request xml")
    end
  end
  
  describe "self.extract_token_from_xml_response" do
    it "gets the token from the expected xml response string" do
      xml_response = fixture_file_contents("covr/max_registrant_response.xml")
      CA.extract_token_from_xml_response(xml_response).should == "F9B91DDE-BD95-41Z-905Z-9143511C32C27C190A"
    end
  end

  describe "self.extract_error_code_from_xml_response" do
    it "gets the token from the expected xml response string" do
      xml_response = fixture_file_contents("covr/max_registrant_response_fail.xml")
      CA.extract_error_code_from_xml_response(xml_response).should == "902"
    end
  end

  describe "self.extract_error_message_from_xml_response" do
    it "gets the token from the expected xml response string" do
      xml_response = fixture_file_contents("covr/max_registrant_response_fail.xml")
      CA.extract_error_message_from_xml_response(xml_response).should == "Invalid voter resident Id"
    end
  end
  
  describe "online_reg_url(registrant)" do
    before(:each) do
      RockyConf.ovr_states.CA.api_settings.stub(:web_url_base).and_return("base_url")
      RockyConf.ovr_states.CA.api_settings.stub(:web_agency_key).and_return("ak")
    end
    it "returns a URL with language and token passed in" do
      r = Registrant.new
      r.stub(:locale).and_return("en")
      r.stub(:covr_token).and_return("token")
      ca.online_reg_url(r).should == "base_url?language=en-US&t=p&CovrAgencyKey=ak&PostingAgencyRecordId=token"
      r.stub(:locale).and_return("zh-tw")
      r.stub(:covr_token).and_return("xxx")
      ca.online_reg_url(r).should == "base_url?language=zh-CN&t=p&CovrAgencyKey=ak&PostingAgencyRecordId=xxx"
      r.stub(:locale).and_return("es")
      r.stub(:covr_token).and_return("xxx")
      ca.online_reg_url(r).should == "base_url?language=es-MX&t=p&CovrAgencyKey=ak&PostingAgencyRecordId=xxx"
    end
  end
  
  describe "ovr_pre_check" do
    let(:reg) { FactoryGirl.create(:step_3_registrant) }
    let(:con) { mock(Step3Controller) }
    before(:each) do
      CA.stub(:build_soap_xml).with(reg).and_return("XML")
      CA.stub(:request_token).with("XML").and_return("stubbed response")
      RockyConf.ovr_states.CA.api_settings.stub(:debug_in_ui).and_return(false)
      con.stub(:debug_data).and_return({})
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
      before(:each) do
        RockyConf.ovr_states.CA.api_settings.stub(:debug_in_ui).and_return(true)
      end
      it "renders the API response" do
        con.should_receive(:debug_data).and_return({})
        ca.ovr_pre_check(reg, con)
      end
    end
    context "when not debugging" do
      context "when the response is a failure" do
        before(:each) do
          CA.stub(:request_token).with("XML").and_return(fixture_file_contents("covr/max_registrant_response_fail.xml"))
        end
        it "logs the error" do
          Rails.logger.should_receive(:warn).with("COVR:: CUSTOM_COVR_ERROR\nError 902: Invalid voter resident Id")
          ca.ovr_pre_check(reg, con)
        end
        it "sets covr_success on the registrant be false" do
          ca.ovr_pre_check(reg, con)
          reg.covr_success.should be_false
          reg.covr_token.should be_nil
        end
      end
      context "when the response is a success" do
        before(:each) do
          CA.stub(:request_token).with("XML").and_return(fixture_file_contents("covr/max_registrant_response.xml"))
        end
        it "sets covr_success on the registrant be true" do
          ca.ovr_pre_check(reg, con)
          reg.covr_success.should be_true
        end
        it "sets the covr_token" do
          ca.ovr_pre_check(reg, con)
          reg.covr_token.should == "F9B91DDE-BD95-41Z-905Z-9143511C32C27C190A"
        end
      end
    end
  end

  describe "decorate_registrant" do
    let(:reg) { FactoryGirl.create(:step_3_registrant) }
    before(:each) do

    end
    it "adds a ca_disclosures method to the registrant" do
      ca.decorate_registrant(reg)
      reg.should respond_to(:ca_disclosures)
    end
    it "adds a ca_disclosures acceptance validation to the registrant" do
      ca.decorate_registrant(reg)
      reg.class.should have(1).validators_on(:ca_disclosures)
    end
    
  end
end
