ActionController::Routing::Routes.draw do |map|
  map.resources "registrants", :only => [:new, :create, :show, :update], :member => {:ineligible => :get, :download => :get, :pdf => :get} do |reg|
    reg.resource "step_1", :controller => "step1", :only => [:show, :update]
    reg.resource "step_2", :controller => "step2", :only => [:show, :update]
    reg.resource "step_3", :controller => "step3", :only => [:show, :update]
    reg.resource "step_4", :controller => "step4", :only => [:show, :update]
    reg.resource "step_5", :controller => "step5", :only => [:show, :update]
  end

  map.resource  "partner_session"
  map.login  "login",  :controller => "partner_sessions", :action => "new"
  map.logout "logout", :controller => "partner_sessions", :action => "destroy"

  map.resource "partner", :path_names => {:new => "register", :edit => "profile"}
  map.widget_loader "partner/:id/widget_loader.js", :format => "js", :controller => "partners", :action => "widget_loader"
end
