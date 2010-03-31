ActionController::Routing::Routes.draw do |map|
  map.root :controller => "registrants", :action => "landing"
  map.registrants_timeout "/registrants/timeout", :controller => "timeouts"
  map.resources "registrants", :only => [:new, :create, :show, :update] do |reg|
    reg.resource "step_1", :controller => "step1", :only => [:show, :update]
    reg.resource "step_2", :controller => "step2", :only => [:show, :update]
    reg.resource "step_3", :controller => "step3", :only => [:show, :update]
    reg.resource "step_4", :controller => "step4", :only => [:show, :update]
    reg.resource "step_5", :controller => "step5", :only => [:show, :update]
    reg.resource "download", :only => :show
    reg.resource "finish", :only => :show
    reg.resource "ineligible", :only => [:show, :update]
    reg.resources "tell_friends", :only => :create
  end

  map.resource  "partner_session"
  map.login  "login",  :controller => "partner_sessions", :action => "new"
  map.logout "logout", :controller => "partner_sessions", :action => "destroy"

  map.resource "partner", :path_names => {:new => "register", :edit => "profile"},
                          :member => {:statistics => :get, :registrations => :get, :embed_codes => :get} do |partner|
    partner.resource "questions",     :only => [:edit, :update]
    partner.resource "widget_image",  :only => [:show, :update]
    partner.resource "logos",         :only => [:show, :update]
  end
  map.widget_loader "partner/:id/widget_loader.js", :format => "js", :controller => "partners", :action => "widget_loader"
  map.resources "password_resets", :only => [:new, :create, :edit, :update]
end
