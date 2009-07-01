ActionController::Routing::Routes.draw do |map|
  map.resources :registrants do |reg|
    reg.resource :step_2, :controller => "step_2"
    reg.resource :step_3, :controller => "step_3"
    reg.resource :step_4, :controller => "step_4"
  end
end
