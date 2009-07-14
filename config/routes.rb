ActionController::Routing::Routes.draw do |map|
  # map.with_options :path_prefix => '/:locale' do |locale|
  #   locale.resources :registrants, :only => [:new, :create] do |reg|
  #     reg.resource :step_1, :controller => "step1", :only => [:show, :update]
  #     reg.resource :step_2, :controller => "step2", :only => [:show, :update]
  #     reg.resource :step_3, :controller => "step3", :only => [:show, :update]
  #     reg.resource :step_4, :controller => "step4", :only => [:show, :update]
  #   end
  # end
  map.resources :registrants, :only => [:new, :create] do |reg|
    reg.resource :step_1, :controller => "step1", :only => [:show, :update]
    reg.resource :step_2, :controller => "step2", :only => [:show, :update]
    reg.resource :step_3, :controller => "step3", :only => [:show, :update]
    reg.resource :step_4, :controller => "step4", :only => [:show, :update]
  end
  map.resources :partners, :member => {:widget_loader => :get}
end
