#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
ActionController::Routing::Routes.draw do |map|
  map.root :controller => "registrants", :action => "landing"
  map.registrants_timeout "/registrants/timeout", :controller => "timeouts"
  map.resources "registrants", :only => [:new, :create, :show, :update] do |reg|
    reg.resource "step_1", :controller => "step1", :only => [:show, :update]
    reg.resource "step_2", :controller => "step2", :only => [:show, :update]
    reg.resource "step_3", :controller => "step3", :only => [:show, :update]
    reg.resource "step_4", :controller => "step4", :only => [:show, :update]
    reg.resource "step_5", :controller => "step5", :only => [:show, :update]
    reg.resource "external", :only => [:show], :member => {:go => :get}
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
    partner.resource "logo",          :only => [:show, :update, :destroy]
  end
  map.widget_loader "/widget_loader.js", :format => "js", :controller => "registrants", :action => "widget_loader"
  map.resources "password_resets", :only => [:new, :create, :edit, :update]


  map.namespace :api do |api|
    api.map '/v1/registrations.json', :format => 'json', :controller => 'registrations', :action => 'index',  :conditions => { :method => :get }
    api.map '/v1/registrations.json', :format => 'json', :controller => 'registrations', :action => 'create', :conditions => { :method => :post }
    api.map '/v1/state_requirements.json', :format => 'json', :controller => 'state_requirements', :action => 'show'
  end

  map.namespace :admin do |admin|
    admin.resources :partners
  end

end
