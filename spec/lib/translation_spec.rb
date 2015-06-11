require 'rails_helper'

describe Translation do
  describe "self.language_name(locale)" do
    it "returns the i18n language key for the locale" do
      I18n.should_receive(:t).with("language_name", :locale=>:loc).and_return("")
      Translation.language_name(:loc)
    end
  end
  
  describe "self.types" do
    it "returns list of translations for each type" do
      Translation.should_receive(:new).with('core')
      Translation.should_receive(:new).with('states')
      Translation.should_receive(:new).with('txt')
      Translation.should_receive(:new).with('email')
      Translation.should_receive(:new).with('pdf')
      Translation.types.should have(5).translations
    end
  end
  
  describe "self.find(type)" do
    it "calls new(type)" do
      Translation.should_receive(:new).with("finder")
      Translation.find("finder")
    end
    
  end
  
  describe "self.instructions_for(key)" do
    before(:each) do
      I18n.stub(:t)
    end
    context "when there are specific instructions" do
      before(:each) do
        I18n.stub(:t).with('key', :locale=>'en').and_return("My translation")
        I18n.stub(:t).with('key_translation_instructions', :locale=>'en', :default=>'').and_return("My specific instructions")
      end
      it "returns specific instructions" do
        Translation.instructions_for('key').should == ["My specific instructions"]
      end
    end
    
    context "when there is an interpolation variable" do
      before(:each) do
        I18n.stub(:t).with('key', :locale=>'en').and_return("My %{variable}")
      end
      it "returns instructions for the variable" do
        Translation.instructions_for('key').should == ["Please keep '%{variable}' intact"]
      end
      
    end
    context "when there are specific instructions and an interpolation variable" do
      before(:each) do
        I18n.stub(:t).with('key', :locale=>'en').and_return("My %{variable}")
        I18n.stub(:t).with('key_translation_instructions', :locale=>'en', :default=>'').and_return("My specific instructions")
        
      end
      it "returns instructions for the variable" do
        Translation.instructions_for('key').should == ["Please keep '%{variable}' intact","My specific instructions"]
      end
    end  
  end
  
  
  
  describe "self.has_css?(locale)" do
    it "checks for a locale css file" do
      File.should_receive("exists?").with(Rails.root.join("app/assets/stylesheets/locales/abc.css.scss").to_s)
      Translation.has_css?("abc")
    end
  end
  
  describe "self.has_nvra_css?(locale)" do
    it "checks for a nvra locale css file" do
      File.should_receive("exists?").with(Rails.root.join("app/assets/stylesheets/nvra/locales/abc.css.scss").to_s)
      Translation.has_nvra_css?("abc")
    end
  end
  
  describe "generating YML from params" do
    let(:params) do
      {
        "en.name"=>"English",
        "en.numbers.one"=>"One",
        "en.numbers.two"=>"Two",
        "en.list"=>["a", "b", "c"],
        "en.blank"=>""
      }
    end
    describe "self.hash_from_form" do
      it "parses a flat form request into nested hash" do
        Translation.hash_from_form(params)[0].should == {
          "en"=> {
            "name"=>"English",
            "numbers"=>{
              "one"=>"One",
              "two"=>"Two"
            },
            "list"=>["a", "b", "c"],
            "blank"=>""
          }
        }
      end
      it "checks for blanks" do
        Translation.hash_from_form(params, true)[1][:blanks].should == ["en.blank"]
      end
      it "checks for variables" do
        Translation.stub(:value_is_missing_variable).and_return(false)
        Translation.stub(:value_is_missing_variable).with("English","en.name").and_return(true)
        Translation.hash_from_form(params, true)[1][:missing_variables].should == ["en.name"]
      end
    end
    describe "#generate_yml(locale, params)" do
      it "sets the content to hashified params for the locale key and return yaml string" do
        t = Translation.new("core")
        hash = t.generate_yml("en", params)
        t.contents["en"].should == {
          "en"=> {
            "name"=>"English",
            "numbers"=>{
              "one"=>"One",
              "two"=>"Two"
            },
            "list"=>["a", "b", "c"],
            "blank"=>""
          }
        }
        hash.should == {
          "en"=> {
            "en"=> {
              "name"=>"English",
              "numbers"=>{
                "one"=>"One",
                "two"=>"Two"
              },
              "list"=>["a", "b", "c"],
              "blank"=>""
            }
          }
        }.to_yaml
      end
    end

    describe "#contents" do
      it "returns the full hash for each language" do
        t = Translation.new("pdf")
        I18n.available_locales.each do |l|
          t.contents.should have_key(l.to_s)
        end
      end
    end
    describe "#get_from_contents(key, locale)" do
      it "breaks out the key into hash parts and returns the value" do
        t = Translation.new("txt")
        t.stub(:contents).and_return({
          "en"=>{
            "numbers"=>{
              "one"=>"1",
              "two"=>"2"
            },
            "name"=>"English"
          }
        })
        t.get_from_contents("numbers.one", "en").should == "1"
        t.get_from_contents("numbers.two", "en").should == "2"
        t.get_from_contents("name", "en").should == "English"
      end
    end
  
    
  end
    
  describe "#has_errors?" do
    it "returns whether there are any blanks or missing variables" do
      t = Translation.new("core")
      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return([])
      t.should_not have_errors
      
      t.stub(:blanks).and_return([1])
      t.stub(:missing_variables).and_return([])
      t.should have_errors
      
      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return([1])
      t.should have_errors
      
      t.stub(:blanks).and_return([1])
      t.stub(:missing_variables).and_return([1])
      t.should have_errors
      
    end
  end
  
  describe "#has_error?(key)" do
    it "returns whether a key is missing a variable or is blank" do
      t = Translation.new("core")
      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return([])
      t.should_not have_error("abc.def")

      t.stub(:blanks).and_return(["abc.def"])
      t.stub(:missing_variables).and_return([])
      t.should have_error("abc.def")

      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return(["abc.def"])
      t.should have_error("abc.def")
      
    end
  end
  
  describe "#is_blank?(key)" do
    it "returns whether a key is blank" do
      t = Translation.new("core")
      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return([])
      t.is_blank?("abc.def").should be_falsey

      t.stub(:blanks).and_return(["abc.def"])
      t.stub(:missing_variables).and_return([])
      t.is_blank?("abc.def").should be_truthy

      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return(["abc.def"])
      t.is_blank?("abc.def").should be_falsey
    end
  end

  describe "#is_missing_variable?(key)" do
    it "returns whether a key is missing a variable" do
      t = Translation.new("core")
      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return([])
      t.is_missing_variable?("abc.def").should be_falsey

      t.stub(:blanks).and_return(["abc.def"])
      t.stub(:missing_variables).and_return([])
      t.is_missing_variable?("abc.def").should be_falsey

      t.stub(:blanks).and_return([])
      t.stub(:missing_variables).and_return(["abc.def"])
      t.is_missing_variable?("abc.def").should be_truthy
    end
  end
  
  describe "#is_email?" do
    it "is true when the type is email" do
      t = Translation.new("email")
      t.is_email?.should be_truthy
    end
    it "is false when the type is not email" do
      t = Translation.new("pdf")
      t.is_email?.should be_falsey
    end
  end
  
  describe "errors" do
    let(:t) { Translation.new("core") }
    before(:each) do
      t.errors[:blanks]="blank obj"
      t.errors[:missing_variables]="mv obj"
    end
    describe "#blanks" do
      it "returns the blanks key from errors" do
        t.blanks.should == "blank obj"
      end
    end
    describe "#blanks=" do
      it "sets the blanks key in errors" do
        t.blanks = "new blank"
        t.errors[:blanks].should == "new blank"
      end
    end
    describe "#missing_variables" do
      it "returns the missing variables key from errors" do
        t.missing_variables.should == "mv obj"
      end
    
    end
    describe "#missing_variables=" do
      it "sets the blanks key in errors" do
        t.missing_variables = "new mv"
        t.errors[:missing_variables].should == "new mv"
      end
    
    end
  end
  
  
  describe "#name" do
    it "returns the type capitalized" do
      t = Translation.new("email")
      t.name.should == "Email"
    end
  end
  
end
