require 'spec_helper'

describe PdfWriter do
  it "responds to the attributes needed for PDF generation" do
    p = PdfWriter.new
    [:id, :uid, :locale,
    :email_address,
    :us_citizen,  
    :will_be_18_by_election,
    :home_zip_code,
    :name_title,      
    :name_title_key,        
    :first_name,         
    :middle_name,        
    :last_name,   
    :name_suffix,    
    :name_suffix_key,        
    :home_address,       
    :home_unit,        
    :home_city,
    :home_state_id,       
    :mailing_address,    
    :mailing_unit,      
    :mailing_city,       
    :mailing_state_id,
    :mailing_zip_code,   
    :phone,       
    :party,   
    :state_id_number,
    :prev_name_title,
    :prev_name_title_key,    
    :prev_first_name,    
    :prev_middle_name,   
    :prev_last_name, 
    :prev_name_suffix,  
    :prev_name_suffix_key,
    :prev_address,   
    :prev_unit,       
    :prev_city,          
    :prev_state_id,
    :prev_zip_code, :partner_absolute_pdf_logo_path,
    :registration_instructions_url,
    :home_state_pdf_instructions,
    :state_registrar_address,
    :registration_deadline,
    :english_party_name,
    :pdf_english_race,
    :pdf_date_of_birth,
    :pdf_barcode,
    :created_at].each do |attribute|
      p.should respond_to(attribute)
      p.should respond_to("#{attribute}=")
    end
  end
  

  describe 'helper attributes' do
    let(:pw) { PdfWriter.new }
    describe "#us_citizen?" do
      it "returns whether us_citizen == true" do
        pw.us_citizen = nil
        pw.us_citizen?.should be_falsey
        pw.us_citizen = "1"
        pw.us_citizen?.should be_falsey
        pw.us_citizen = "true"
        pw.us_citizen?.should be_falsey
        pw.us_citizen = true
        pw.us_citizen?.should be_truthy        
      end
    end
    
    describe '#will_be_18_by_election?' do
      it "returns whether will_be_18_by_election == true" do
        pw.will_be_18_by_election = nil
        pw.will_be_18_by_election?.should be_falsey
        pw.will_be_18_by_election = "1"
        pw.will_be_18_by_election?.should be_falsey
        pw.will_be_18_by_election = "true"
        pw.will_be_18_by_election?.should be_falsey
        pw.will_be_18_by_election = true
        pw.will_be_18_by_election?.should be_truthy        
      end
    end

    describe 'yes_no values' do
      it "returns 'Yes' or 'No' based on the value of the attribute" do
        pw.stub(:attrib).and_return(true)
        pw.yes_no_attrib.should == "Yes"
        
        pw.stub(:attrib).and_return(false)
        pw.yes_no_attrib.should == "No"
        
        pw.stub(:attrib).and_return("text")
        pw.yes_no_attrib.should == "Yes"

        pw.stub(:attrib).and_return(nil)
        pw.yes_no_attrib.should == "No"
      end
    end
        
  end
  
  describe 'pdf_dob values' do
    let(:pw) { PdfWriter.new }
    before(:each) do
      pw.pdf_date_of_birth = "12/34/5678"
    end
    it "validates pdf_date_of_birth format" do
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should be_empty

      pw.pdf_date_of_birth = "12/3/567"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should be_empty

      pw.pdf_date_of_birth = "2/23/567"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should be_empty

      pw.pdf_date_of_birth = "2/3/567"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should be_empty
      
      pw.pdf_date_of_birth = "12/343/5674"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should have(1).messsage

      pw.pdf_date_of_birth = "1/343/5674"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should have(1).messsage

      pw.pdf_date_of_birth = "12/5674"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should have(1).messsage

      pw.pdf_date_of_birth = "12/56"
      pw.valid?
      pw.errors_on(:pdf_date_of_birth).should have(1).messsage
    end

    describe 'pdf_date_of_birth_day' do
      it "should return the day part" do
        pw.pdf_date_of_birth_day.should == "34"
      end
    end
    describe 'pdf_date_of_birth_month' do
      it "should return the month part" do
        pw.pdf_date_of_birth_month.should == "12"
      end
    end
    describe 'pdf_date_of_birth_year' do
      it "should return the year part" do
        pw.pdf_date_of_birth_year.should == "5678"
      end
    end
  end
  
  describe '#registrant_to_html_string' do
    let(:r) { FactoryGirl.create(:maximal_registrant) }
    let(:pw) { r.pdf_writer }
    before(:each) do
      PdfRenderer.any_instance.stub(:render_to_string)
    end
    it "returns false if the locale is blank" do
      pw.locale = ''
      pw.registrant_to_html_string.should be_falsey
    end
    it "returns false if the home_state_id is blank" do
      pw.home_state_id = ''
      pw.registrant_to_html_string.should be_falsey
    end
    it "sets the locale for rendering and resets after rending" do
      pw.locale = 'es'
      I18n.should_receive("locale=").with("es")
      I18n.should_receive("locale=").with(:en)
      pw.registrant_to_html_string
    end
    it "uses the PdfRenderer" do
      renderer = mock(PdfRenderer)
      renderer.stub(:render_to_string).and_return("html output")
      PdfRenderer.should_receive(:new).with(pw).and_return(renderer)
      pw.registrant_to_html_string.should == "html output"
    end
  end
  
  describe 'generate_html' do
    let(:r) { FactoryGirl.create(:maximal_registrant) }
    let(:pw) { r.pdf_writer }
    before(:each) do
      pw.stub(:html_file_path).and_return("html_path")
      pw.stub(:html_exists?).and_return(false)
      PdfWriter.stub(:write_html_from_html_string)
    end
    it "returns false if the html string doesn't generate" do
      pw.stub(:registrant_to_html_string).and_return(false)
      pw.generate_html.should be_blank
    end
    it "generates a file" do
      PdfWriter.should_receive(:write_html_from_html_string)
      pw.generate_html
    end
    context 'file exists' do
      before(:each) do
        pw.stub(:html_exists?).and_return(true)
      end
      it "doesn't generate a file if it already exists" do
        PdfWriter.should_not_receive(:write_html_from_html_string)
        pw.generate_html
      end
      it "generates a file if force is true" do
        PdfWriter.should_receive(:write_html_from_html_string)
        pw.generate_html(true)
      end
    end
  end
  describe 'generate_pdf' do
    let(:r) { FactoryGirl.create(:maximal_registrant) }
    let(:pw) { r.pdf_writer }
    before(:each) do
      pw.stub(:pdf_file_path).and_return("pdf_path")
      pw.stub(:pdf_exists?).and_return(false)
      PdfWriter.stub(:write_pdf_from_html_string)
    end
    it "returns false if the html string doesn't generate" do
      pw.stub(:registrant_to_html_string).and_return(false)
      pw.generate_pdf.should be_blank
    end
    it "generates a file" do
      PdfWriter.should_receive(:write_pdf_from_html_string)
      pw.generate_pdf
    end
    
    context 'file exists' do
      before(:each) do
        pw.stub(:pdf_exists?).and_return(true)
      end
      it "doesn't generate a file if it already exists" do
        PdfWriter.should_not_receive(:write_pdf_from_html_string)
        pw.generate_pdf
      end
      it "generates a file if force is true" do
        PdfWriter.should_receive(:write_pdf_from_html_string)
        pw.generate_pdf(true)
      end
    end
  end
  
  describe '.write_html_from_html_string' do
    let(:r) { FactoryGirl.create(:maximal_registrant) }
    let(:pw) { r.pdf_writer }
    let(:fstream) { mock(Object) }
    let(:html) { "html" }
    before(:each) do
      FileUtils.stub(:mkdir_p).with("dir")
      fstream.stub(:<<)
      html.stub(:force_encoding).and_return("html")
      File.stub(:open).with("path", "w").and_yield(fstream)
    end
    it "makes the directory" do
      FileUtils.should_receive(:mkdir_p).with("dir")
      PdfWriter.write_html_from_html_string(html, "dir", "path")
    end
    it "writes the file from the string" do
      File.should_receive(:open)
      html.should_receive(:force_encoding)
      fstream.should_receive(:<<).with("html")
      PdfWriter.write_html_from_html_string(html, "dir", "path")
    end
    
  end
  
  describe '.write_pdf_from_html_string' do
    let(:r) { FactoryGirl.create(:maximal_registrant) }
    let(:pw) { r.pdf_writer }
    let(:fstream) { mock(Object) }
    let(:pdf) { "pdf" }
    let(:wpdf) { mock(Object) }
    before(:each) do
      FileUtils.stub(:mkdir_p).with("dir")
      fstream.stub(:<<)
      File.stub(:open).with("path", "w").and_yield(fstream)
      pdf.stub(:force_encoding).and_return("pdf")
      wpdf.stub(:pdf_from_string).and_return(pdf)
      WickedPdf.stub(:new).and_return(wpdf)
    end
    it "generates PDF contents" do
      WickedPdf.should_receive(:new)
      wpdf.should_receive(:pdf_from_string)
      PdfWriter.write_pdf_from_html_string("html", "path", "locale", "dir")
    end
    
    it "makes the directory" do
      FileUtils.should_receive(:mkdir_p).with("dir")
      PdfWriter.write_pdf_from_html_string("html", "path", "locale", "dir")
    end
    
    it "writes the file from the string" do
      File.should_receive(:open)
      pdf.should_receive(:force_encoding)
      fstream.should_receive(:<<).with("pdf")
      PdfWriter.write_pdf_from_html_string("html", "path", "locale", "dir")
    end
  end
  
  
end

