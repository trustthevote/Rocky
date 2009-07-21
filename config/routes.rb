ActionController::Routing::Routes.draw do |map|
  map.resources :registrants, :only => [:new, :create] do |reg|
    reg.resource :step_1, :controller => "step1", :only => [:show, :update]
    reg.resource :step_2, :controller => "step2", :only => [:show, :update]
    reg.resource :step_3, :controller => "step3", :only => [:show, :update]
    reg.resource :step_4, :controller => "step4", :only => [:show, :update]
  end
  map.resource  :partner_session
  map.resources :partners, :member => {:widget_loader => :get}
  map.resource  :dashboard, :controller => :partners
end
