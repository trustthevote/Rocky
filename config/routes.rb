ActionController::Routing::Routes.draw do |map|
  map.resources :registrants do |reg|   # , :only => [:new, :create]
    reg.resource :step_1, :controller => "step1", :only => [:show, :update]
    reg.resource :step_2, :controller => "step2", :only => [:show, :update]
    reg.resource :step_3, :controller => "step3", :only => [:show, :update]
    reg.resource :step_4, :controller => "step4", :only => [:show, :update]
  end
end
