ActionController::Routing::Routes.draw do |map|
  map.resources :registrants do |reg|
    reg.resource :step_2, :controller => "step2"
    reg.resource :step_3, :controller => "step3"
    reg.resource :step_4, :controller => "step4"
  end
end
