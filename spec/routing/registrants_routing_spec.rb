require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrantsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "registrants", :action => "index").should == "/registrants"
    end

    it "maps #new" do
      route_for(:controller => "registrants", :action => "new").should == "/registrants/new"
    end

    it "maps #show" do
      route_for(:controller => "registrants", :action => "show", :id => "1").should == "/registrants/1"
    end

    it "maps #edit" do
      route_for(:controller => "registrants", :action => "edit", :id => "1").should == "/registrants/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "registrants", :action => "create").should == {:path => "/registrants", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "registrants", :action => "update", :id => "1").should == {:path =>"/registrants/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "registrants", :action => "destroy", :id => "1").should == {:path =>"/registrants/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/registrants").should == {:controller => "registrants", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/registrants/new").should == {:controller => "registrants", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/registrants").should == {:controller => "registrants", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/registrants/1").should == {:controller => "registrants", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/registrants/1/edit").should == {:controller => "registrants", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/registrants/1").should == {:controller => "registrants", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/registrants/1").should == {:controller => "registrants", :action => "destroy", :id => "1"}
    end
  end
end
