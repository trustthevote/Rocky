require 'spec_helper'

describe PdfGeneration do
  
  it "requires registrant" do
    p = PdfGeneration.new
    p.should_not be_valid
    p.errors_on(:registrant_id).should have(1).message
  end
  
  describe '.retrieve' do
    let(:selector) { mock(Object) }
    before(:each) do
      selector.stub(:lock).and_return(selector)
      selector.stub(:first).and_return(selector)
      selector.stub(:locked=)
      selector.stub(:save!)
      selector.stub(:id).and_return("row_id")
      PdfGeneration.stub(:where).and_return(selector)
    end
    it "locks a PdfGeneration row for a transaction and sets the 'locked' field to true" do
      PdfGeneration.should_receive(:where)
      selector.should_receive(:lock).with(true)
      selector.should_receive(:first)
      selector.should_receive(:locked=).with(true)
      selector.should_receive(:save!)
      selector.should_receive(:id)
      PdfGeneration.retrieve
    end
    it "returns a row id" do
      PdfGeneration.retrieve.should == "row_id"
    end
    context 'Now rows avaialable' do
      before(:each) do
        selector.stub(:first).and_return(nil, selector)
        selector.stub(:where).and_return(selector)
        selector.stub(:id).and_return("row_id2")
      end
      it "looks for an old locked row" do
        selector.should_receive(:locked=).with(true)
        selector.should_receive(:updated_at=)
        selector.should_receive(:save!)
        selector.should_receive(:id)
        
        PdfGeneration.retrieve.should == "row_id2"
      end
      context 'no old rows available' do
        before(:each) do
          selector.stub(:first).and_return(nil)
          PdfGeneration.stub(:sleep)
        end
        it "pauses before returning" do
          PdfGeneration.should_receive(:sleep)
          PdfGeneration.retrieve
        end
        context 'when there are rows it should be retrieving' do
          before(:each) do
            PdfGeneration.stub(:count).and_return(1)
          end
          it "logs a warning" do
            Rails.logger.should_receive(:warn)
            PdfGeneration.retrieve
          end
        end
      end
    end
  end
  
  describe '.find_and_generate' do
    let(:pdfgen) { mock(PdfGeneration)}
    let(:r) { mock(Registrant) }
    
    before(:each) do
      PdfGeneration.stub(:retrieve).and_return("pdfgen_id")
      PdfGeneration.stub(:find).with("pdfgen_id", {:include=>:registrant}).and_return(pdfgen)
      pdfgen.stub(:registrant).and_return(r)
      pdfgen.stub(:delete).and_return(true)
      r.stub(:generate_pdf).and_return(true)
      r.stub(:finalize_pdf)
    end
    
    it "retrieves an id" do
      PdfGeneration.should_receive(:retrieve)
      PdfGeneration.find_and_generate.should be_true
    end
    
    it "retrieves the registrant" do
      PdfGeneration.should_receive(:find).with("pdfgen_id", {:include=>:registrant})
      PdfGeneration.find_and_generate.should be_true
    end
    
    it "generates the pdf" do
      r.should_receive(:generate_pdf)
      PdfGeneration.find_and_generate.should be_true
    end
    it "finishes the pdf gen" do
      r.should_receive(:finalize_pdf)
      PdfGeneration.find_and_generate.should be_true
    end
    it "deletes the pdfgen row" do
      pdfgen.should_receive(:delete)
      PdfGeneration.find_and_generate.should be_true
    end
    
    context 'when there is no registrant' do
      before(:each) do
        pdfgen.stub(:registrant).and_return(nil)
      end
      it "doesn't finish the pdf gen or delete the row" do
        r.should_not_receive(:generate_pdf)
        r.should_not_receive(:finalize_pdf)
        pdfgen.should_not_receive(:delete)
        PdfGeneration.find_and_generate
      end
      it "logs an error" do
        Rails.logger.should_receive(:error)
        PdfGeneration.find_and_generate
      end
    end
    context 'when the pdf fails to generate' do
      before(:each) do
        r.stub(:generate_pdf).and_return(false)
      end
      it "doesn't finish the pdf gen or delete the row" do
        r.should_not_receive(:finalize_pdf)
        pdfgen.should_not_receive(:delete)
        PdfGeneration.find_and_generate
      end
      it "logs an error" do
        Rails.logger.should_receive(:error)
        PdfGeneration.find_and_generate
      end
    end
    context 'when the pdfgenid is nil' do
      it "returns false" do
        PdfGeneration.stub(:retrieve).and_return(nil)
        PdfGeneration.find_and_generate.should be_false
      end
    end
  end
  
end
